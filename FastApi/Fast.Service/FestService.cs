using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.IO;
using System.Linq;
using Fast.Data;
using Fast.Data.Model.Fest;
using FuzzyMatch;

namespace Fast.Service
{
    public class FestService
    {
        private readonly string _festFilePath;

        private readonly FEST _festData;
        // private readonly Dictionary<string, (SubstansgruppeSubstans, SubstansgruppeSubstans, Interaksjon)> _preprocessedInteraksjoner;
        private readonly InteraksjonCouple[] _preprocessedInteraksjoner;

        public FestService()
        {
            _festFilePath = @"C:\Users\nilsh\Downloads\fest251\fest251.xml";
            _festData = FestParser.LoadFest(() => File.OpenRead(_festFilePath));
            _preprocessedInteraksjoner = _festData
            .KatInteraksjon
            .Select(x => x.Item as Interaksjon)
            .Where(x => x != null)
            .SelectMany(x =>
            {
                var res = new List<InteraksjonCouple>();
                foreach (var substansgruppe in x.Substansgruppe)
                {
                    var restSubstansgrupper = x.Substansgruppe.Except(new[] { substansgruppe }).ToArray();
                    foreach (var substans in substansgruppe.Substans)
                    {
                        foreach (var restSubstansgruppe in restSubstansgrupper)
                        {
                            foreach (var restSubstans in restSubstansgruppe.Substans)
                                res.Add(new InteraksjonCouple { SubstansA = substans, SubstansB = restSubstans, Interaksjon = x });
                        }
                    }
                }
                return res;
            }).ToArray();//(x => x.Item1.Atc?.V, y => (y.Item1, y.Item2, y.Item3));
        }




        public Interaksjon GetInteraksjon(string id)
        {
            const string StatusAktiv = "A";
            return _festData.KatInteraksjon
                .Where(x => x.Status.V == StatusAktiv)
                .Select(x => x.Item as Interaksjon)
                .Where(y => y != null && y.Id == id).FirstOrDefault();
        }

        public LegemiddelVirkestoff[] AllLegemiddelVirkestoff(string search, int take, int skip)
        {
            var query = _festData.KatLegemiddelVirkestoff.AsEnumerable();


            if (!string.IsNullOrWhiteSpace(search))
            {
                var searchWithoutWhitespace = search.Replace(" ", "");
                query = query.AsParallel().Select(x =>
                {

                    return (x, fuzz: FuzzyMatch.FuzzyMatcher.FuzzyMatch(x.LegemiddelVirkestoff.Atc.DN, search, false, false));


                })
                .Where(x => x.fuzz.DidMatch || x.x.LegemiddelVirkestoff.Atc?.V.StartsWith(searchWithoutWhitespace) == true)
                .OrderByDescending(x => x.fuzz.Score)
                .Select(x => x.x);
            }

            return query.Skip(skip)
                .Take(take)
                .Select(x => x.LegemiddelVirkestoff)
                .ToArray();
        }

        public LegemiddelMerkevare[] AllLegemiddelMerkevare(string nameContains, int take, int skip)
        {
            var query = _festData.KatLegemiddelMerkevare.AsEnumerable();

            if (nameContains != null)
                query = query.AsParallel().Select(x => (x, fuzz: FuzzyMatch.FuzzyMatcher.FuzzyMatch(x.LegemiddelMerkevare.NavnFormStyrke, nameContains, false, false)))
                                .Where(x => x.fuzz.DidMatch || x.x.LegemiddelMerkevare.Atc?.V.StartsWith(nameContains) == true)
                                .OrderByDescending(x => x.fuzz.Score)
                                .Select(x => x.x);



            return query.Skip(skip)
                .Take(take)
                .Select(x => x.LegemiddelMerkevare)
                .ToArray();
        }

        public Interaksjon[] FindInteraksjon(string[] atcVs)
        {
            if (atcVs == null)
                return Array.Empty<Interaksjon>();

            // TODO: Handle empty atcvs
            atcVs = atcVs.Where(x => !string.IsNullOrWhiteSpace(x)).ToArray();

            return _festData.KatInteraksjon
                .Select(x => x.Item as Interaksjon)
                .Where(x => x != null && x.Substansgruppe.Any(x => x.Substans.Any(y => atcVs.Contains(y.Atc?.V, StringComparer.InvariantCultureIgnoreCase))))
                .ToArray();
        }

        public InteraksjonCouple[] FindInteraksjonVirkestoff(string[] atcVs)
        {
            if (atcVs == null)
                return Array.Empty<InteraksjonCouple>();

            return _preprocessedInteraksjoner
                .Where(x => atcVs.Contains(x.SubstansA.Atc?.V)
                            && ((atcVs.Length != 1) ? atcVs.Contains(x.SubstansB.Atc?.V) : true))
                .Distinct()
                .ToArray();
        }
    }
}

