//
//  CountriesSettings.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 10/21/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation

public struct Country: Equatable {
    public var name: String
    public var isoCode: String
    
}

public func == (lhs: Country, rhs: Country) -> Bool {
    return lhs.name == rhs.name
}


public struct Countries {
    
    public static let DefaultCountry: Country  = Country(name: "Select a country", isoCode: "")
    public static let UnitedKingdom: Country = Country(name:"United Kingdom", isoCode:"GB")
    public static let UnitedStates: Country = Country(name:"United States", isoCode:"US")
    public static let Germany: Country = Country(name:"Germany", isoCode:"DE")

    public static let Afghanistan: Country = Country(name:"Afghanistan", isoCode:"AF")
    public static let AlandIsland: Country = Country(name:"Aland Islands", isoCode:"AX")
    public static let Albania: Country = Country(name:"Albania", isoCode:"AL")
    public static let Algeria: Country = Country(name:"Algeria", isoCode:"DZ")
    public static let AmericanSamoa: Country = Country(name:"American Samoa", isoCode:"AS")
    public static let Andorra: Country = Country(name:"Andorra", isoCode:"AD")
    public static let Angola: Country = Country(name:"Angola", isoCode:"AO")
    public static let Anguilla: Country = Country(name:"Anguilla", isoCode:"AI")
    public static let Antarctica: Country = Country(name:"Antarctica", isoCode:"AQ")
    public static let AntiguaAndBarbuda: Country = Country(name:"Antigua and Barbuda", isoCode:"AG")
    public static let Argentina: Country = Country(name:"Argentina", isoCode:"AR")
    public static let Armenia: Country = Country(name:"Armenia", isoCode:"AM")
    public static let Aruba: Country = Country(name:"Aruba", isoCode:"AW")
    public static let AscensionIsland: Country = Country(name:"Ascension Island", isoCode:"AC")
    public static let Australia: Country = Country(name:"Australia", isoCode:"AU")
    public static let Austria: Country = Country(name:"Austria", isoCode:"AT")
    public static let Azerbaijan: Country = Country(name:"Azerbaijan", isoCode:"AZ")
    public static let Bahamas: Country = Country(name:"Bahamas", isoCode:"BS")
    public static let Bahrain: Country = Country(name:"Bahrain", isoCode:"BH")
    public static let Bangladesh: Country = Country(name:"Bangladesh", isoCode:"BD")
    public static let Barbados: Country = Country(name:"Barbados", isoCode:"BB")
    public static let Belarus: Country = Country(name:"Belarus", isoCode:"BY")
    public static let Belgium: Country = Country(name:"Belgium", isoCode:"BE")
    public static let Belize: Country = Country(name:"Belize", isoCode:"BZ")
    public static let Benin: Country = Country(name:"Benin", isoCode:"BJ")
    public static let Bermuda: Country = Country(name:"Bermuda", isoCode:"BM")
    public static let Bhutan: Country = Country(name:"Bhutan", isoCode:"BT")
    public static let Bolivia: Country = Country(name:"Bolivia", isoCode:"BO")
    public static let BosniaAndHerzegovina: Country = Country(name:"Bosnia and Herzegovina", isoCode:"BA")
    public static let Botswana: Country = Country(name:"Botswana", isoCode:"BW")
    public static let BouvetIsland: Country = Country(name:"Bouvet Island", isoCode:"BV")
    public static let Brazil: Country = Country(name:"Brazil", isoCode:"BR")
    public static let BritishIndianOceanTerritory: Country = Country(name:"British Indian Ocean Territory", isoCode:"IO")
    public static let BritishVirginIslands: Country = Country(name:"British Virgin Islands", isoCode:"VG")
    public static let Brunei: Country = Country(name:"Brunei", isoCode:"BN")
    public static let Bulgaria: Country = Country(name:"Bulgaria", isoCode:"BG")
    public static let BurkinaFaso: Country = Country(name:"Burkina Faso", isoCode:"BF")
    public static let Burundi: Country = Country(name:"Burundi", isoCode:"BI")
    public static let Cambodia: Country = Country(name:"Cambodia", isoCode:"KH")
    public static let Cameroon: Country = Country(name:"Cameroon", isoCode:"CM")
    public static let Canada: Country = Country(name:"Canada", isoCode:"CA")
    public static let CanaryIslands: Country = Country(name:"Canary Islands", isoCode:"IC")
    public static let CapeVerde: Country = Country(name:"Cape Verde", isoCode:"CV")
    public static let CaymanIslands: Country = Country(name:"Cayman Islands", isoCode:"KY")
    public static let CentralAfricanRepubli: Country = Country(name:"Central African Republic", isoCode:"CF")
    public static let Chad: Country = Country(name:"Chad", isoCode:"TD")
    public static let Chile: Country = Country(name:"Chile", isoCode:"CL")
    public static let China: Country = Country(name:"China", isoCode:"CN")
    public static let ChristmasIsland: Country = Country(name:"Christmas Island", isoCode:"CX")
    public static let CocosIslands: Country = Country(name:"Cocos [Keeling] Islands", isoCode:"CC")
    public static let Colombia: Country = Country(name:"Colombia", isoCode:"CO")
    public static let Comoros: Country = Country(name:"Comoros", isoCode:"KM")
    public static let CongoBrazzaville: Country = Country(name:"Congo - Brazzaville", isoCode:"CG")
    public static let CongoKinshasa: Country = Country(name:"Congo - Kinshasa", isoCode:"CD")
    public static let CookIslands: Country = Country(name:"Cook Islands", isoCode:"CK")
    public static let CostaRica: Country = Country(name:"Costa Rica", isoCode:"CR")
    public static let CoteDIvoire: Country = Country(name:"Cote d’Ivoire", isoCode:"CI")
    public static let Croatia: Country = Country(name:"Croatia", isoCode:"HR")
    public static let Cuba: Country = Country(name:"Cuba", isoCode:"CU")
    public static let Curacao: Country = Country(name:"Curacao", isoCode:"CW")
    public static let Cyprus: Country = Country(name:"Cyprus", isoCode:"CY")
    public static let CzechRepublic: Country = Country(name:"Czech Republic", isoCode:"CZ")
    public static let Denmark: Country = Country(name:"Denmark", isoCode:"DK")
    public static let Djibouti: Country = Country(name:"Djibouti", isoCode:"DJ")
    public static let Dominica: Country = Country(name:"Dominica", isoCode:"DM")
    public static let DominicaRepublic: Country = Country(name:"Dominican Republic", isoCode:"DO")
    public static let Ecuador: Country = Country(name:"Ecuador", isoCode:"EC")
    public static let Egypt: Country = Country(name:"Egypt", isoCode:"EG")
    public static let ElSalvador: Country = Country(name:"El Salvador", isoCode:"SV")
    public static let EquatorialGuinea: Country = Country(name:"Equatorial Guinea", isoCode:"GQ")
    public static let Eritrea: Country = Country(name:"Eritrea", isoCode:"ER")
    public static let Estonia: Country = Country(name:"Estonia", isoCode:"EE")
    public static let Ethiopia: Country = Country(name:"Ethiopia", isoCode:"ET")
    public static let FalklandIslands: Country = Country(name:"Falkland Islands", isoCode:"FK")
    public static let FaroeIslands: Country = Country(name:"Faroe Islands", isoCode:"FO")
    public static let Fiji: Country = Country(name:"Fiji", isoCode:"FJ")
    public static let Finland: Country = Country(name:"Finland", isoCode:"FI")
    public static let France: Country = Country(name:"France", isoCode:"FR")
    public static let FrenchGuiana: Country = Country(name:"French Guiana", isoCode:"GF")
    public static let FrenchPolynesia: Country = Country(name:"French Polynesia", isoCode:"PF")
    public static let FrenchSouthernTerritories: Country = Country(name:"French Southern Territories", isoCode:"TF")
    public static let Gabon: Country = Country(name:"Gabon", isoCode:"GA")
    public static let Gambia: Country = Country(name:"Gambia", isoCode:"GM")
    public static let Georgia: Country = Country(name:"Georgia", isoCode:"GE")
    public static let Ghana: Country = Country(name:"Ghana", isoCode:"GH")
    public static let Gibraltar: Country = Country(name:"Gibraltar", isoCode:"GI")
    public static let Greece: Country = Country(name:"Greece", isoCode:"GR")
    public static let Greenland: Country = Country(name:"Greenland", isoCode:"GL")
    public static let Grenada: Country = Country(name:"Grenada", isoCode:"GD")
    public static let Guadeloupe: Country = Country(name:"Guadeloupe", isoCode:"GP")
    public static let Guam: Country = Country(name:"Guam", isoCode:"GU")
    public static let Guatemala: Country = Country(name:"Guatemala", isoCode:"GT")
    public static let Guernsey: Country = Country(name:"Guernsey", isoCode:"GG")
    public static let Guinea: Country = Country(name:"Guinea", isoCode:"GN")
    public static let GuineaBissau: Country = Country(name:"Guinea-Bissau", isoCode:"GW")
    public static let Guyana: Country = Country(name:"Guyana", isoCode:"GY")
    public static let Haiti: Country = Country(name:"Haiti", isoCode:"HT")
    public static let HeardIsland: Country = Country(name:"Heard Island and McDonald Islands", isoCode:"HM")
    public static let Honduras: Country = Country(name:"Honduras", isoCode:"HN")
    public static let HongKong: Country = Country(name:"Hong Kong", isoCode:"HK")
    public static let Hungary: Country = Country(name:"Hungary", isoCode:"HU")
    public static let Iceland: Country = Country(name:"Iceland", isoCode:"IS")
    public static let India: Country = Country(name:"India", isoCode:"IN")
    public static let Indonesia: Country = Country(name:"Indonesia", isoCode:"ID")
    public static let Iran: Country = Country(name:"Iran", isoCode:"IR")
    public static let Iraq: Country = Country(name:"Iraq", isoCode:"IQ")
    public static let Ireland: Country = Country(name:"Ireland", isoCode:"IE")
    public static let IsleOfMan: Country = Country(name:"Isle of Man", isoCode:"IM")
    public static let Israel: Country = Country(name:"Israel", isoCode:"IL")
    public static let Italy: Country = Country(name:"Italy", isoCode:"IT")
    public static let Jamaica: Country = Country(name:"Jamaica", isoCode:"JM")
    public static let Japan: Country = Country(name:"Japan", isoCode:"JP")
    public static let Jersey: Country = Country(name:"Jersey", isoCode:"JE")
    public static let Jordan: Country = Country(name:"Jordan", isoCode:"JO")
    public static let Kazakhstan: Country = Country(name:"Kazakhstan", isoCode:"KZ")
    public static let Kenya: Country = Country(name:"Kenya", isoCode:"KE")
    public static let Kiribati: Country = Country(name:"Kiribati", isoCode:"KI")
    public static let Kosovo: Country = Country(name:"Kosovo", isoCode:"XK")
    public static let Kuwait: Country = Country(name:"Kuwait", isoCode:"KW")
    public static let Kyrgyzstan: Country = Country(name:"Kyrgyzstan", isoCode:"KG")
    public static let Laos: Country = Country(name:"Laos", isoCode:"LA")
    public static let Latvia: Country = Country(name:"Latvia", isoCode:"LV")
    public static let Lebanon: Country = Country(name:"Lebanon", isoCode:"LB")
    public static let Lesotho: Country = Country(name:"Lesotho", isoCode:"LS")
    public static let Liberia: Country = Country(name:"Liberia", isoCode:"LR")
    public static let Libya: Country = Country(name:"Libya", isoCode:"LY")
    public static let Liechtenstein: Country = Country(name:"Liechtenstein", isoCode:"LI")
    public static let Lithuania: Country = Country(name:"Lithuania", isoCode:"LT")
    public static let Luxembourg: Country = Country(name:"Luxembourg", isoCode:"LU")
    public static let Macau: Country = Country(name:"Macau", isoCode:"MO")
    public static let Macedonia: Country = Country(name:"Macedonia", isoCode:"MK")
    public static let Madagascar: Country = Country(name:"Madagascar", isoCode:"MG")
    public static let Malawi: Country = Country(name:"Malawi", isoCode:"MW")
    public static let Malaysia: Country = Country(name:"Malaysia", isoCode:"MY")
    public static let Maldives: Country = Country(name:"Maldives", isoCode:"MV")
    public static let Mali: Country = Country(name:"Mali", isoCode:"ML")
    public static let Malta: Country = Country(name:"Malta", isoCode:"MT")
    public static let MarshallIslands: Country = Country(name:"Marshall Islands", isoCode:"MH")
    public static let Martinique: Country = Country(name:"Martinique", isoCode:"MQ")
    public static let Mauritania: Country = Country(name:"Mauritania", isoCode:"MR")
    public static let Mauritius: Country = Country(name:"Mauritius", isoCode:"MU")
    public static let Mayotte: Country = Country(name:"Mayotte", isoCode:"YT")
    public static let Mexico: Country = Country(name:"Mexico", isoCode:"MX")
    public static let Micronesia: Country = Country(name:"Micronesia", isoCode:"FM")
    public static let Moldova: Country = Country(name:"Moldova", isoCode:"MD")
    public static let Monaco: Country = Country(name:"Monaco", isoCode:"MC")
    public static let Mongolia: Country = Country(name:"Mongolia", isoCode:"MN")
    public static let Montenegro: Country = Country(name:"Montenegro", isoCode:"ME")
    public static let Montserrat: Country = Country(name:"Montserrat", isoCode:"MS")
    public static let Morocco: Country = Country(name:"Morocco", isoCode:"MA")
    public static let Mozambique: Country = Country(name:"Mozambique", isoCode:"MZ")
    public static let Myanmar: Country = Country(name:"Myanmar [Burma]", isoCode:"MM")
    public static let Namibia: Country = Country(name:"Namibia", isoCode:"NA")
    public static let Nauru: Country = Country(name:"Nauru", isoCode:"NR")
    public static let Nepal: Country = Country(name:"Nepal", isoCode:"NP")
    public static let Netherlands: Country = Country(name:"Netherlands", isoCode:"NL")
    public static let NetherlandsAntilles: Country = Country(name:"Netherlands Antilles", isoCode:"AN")
    public static let NewCaledonia: Country = Country(name:"New Caledonia", isoCode:"NC")
    public static let NewZealand: Country = Country(name:"New Zealand", isoCode:"NZ")
    public static let Nicaragua: Country = Country(name:"Nicaragua", isoCode:"NI")
    public static let Niger: Country = Country(name:"Niger", isoCode:"NE")
    public static let Nigeria: Country = Country(name:"Nigeria", isoCode:"NG")
    public static let Niue: Country = Country(name:"Niue", isoCode:"NU")
    public static let NorfolkIsland: Country = Country(name:"Norfolk Island", isoCode:"NF")
    public static let NorthKorea: Country = Country(name:"North Korea", isoCode:"KP")
    public static let NorthernMarianaIslands: Country = Country(name:"Northern Mariana Islands", isoCode:"MP")
    public static let Norway: Country = Country(name:"Norway", isoCode:"NO")
    public static let Oman: Country = Country(name:"Oman", isoCode:"OM")
    public static let Pakistan: Country = Country(name:"Pakistan", isoCode:"PK")
    public static let Palau: Country = Country(name:"Palau", isoCode:"PW")
    public static let PalestinianTerritories: Country = Country(name:"Palestinian Territories", isoCode:"PS")
    public static let Panama: Country = Country(name:"Panama", isoCode:"PA")
    public static let PapuaNewGuinea: Country = Country(name:"Papua New Guinea", isoCode:"PG")
    public static let Paraguay: Country = Country(name:"Paraguay", isoCode:"PY")
    public static let Peru: Country = Country(name:"Peru", isoCode:"PE")
    public static let Philippines: Country = Country(name:"Philippines", isoCode:"PH")
    public static let PitcairnIslands: Country = Country(name:"Pitcairn Islands", isoCode:"PN")
    public static let Poland: Country = Country(name:"Poland", isoCode:"PL")
    public static let Portugal: Country = Country(name:"Portugal", isoCode:"PT")
    public static let PuertoRico: Country = Country(name:"Puerto Rico", isoCode:"PR")
    public static let Qatar: Country = Country(name:"Qatar", isoCode:"QA")
    public static let Réunion: Country = Country(name:"Réunion", isoCode:"RE")
    public static let Romania: Country = Country(name:"Romania", isoCode:"RO")
    public static let Russia: Country = Country(name:"Russia", isoCode:"RU")
    public static let Rwanda: Country = Country(name:"Rwanda", isoCode:"RW")
    public static let SaintHelena: Country = Country(name:"Saint Helena", isoCode:"SH")
    public static let SaintKitts: Country = Country(name:"Saint Kitts and Nevis", isoCode:"KN")
    public static let SaintLucia: Country = Country(name:"Saint Lucia", isoCode:"LC")
    public static let SaintMartin: Country = Country(name:"Saint Martin", isoCode:"MF")
    public static let SaintPierre: Country = Country(name:"Saint Pierre and Miquelon", isoCode:"PM")
    public static let SaintVincent: Country = Country(name:"Saint Vincent and the Grenadines", isoCode:"VC")
    public static let Samoa: Country = Country(name:"Samoa", isoCode:"WS")
    public static let SanMarino: Country = Country(name:"San Marino", isoCode:"SM")
    public static let SaoTome: Country = Country(name:"Sao Tome and Principe", isoCode:"ST")
    public static let SaudiArabia: Country = Country(name:"Saudi Arabia", isoCode:"SA")
    public static let Senegal: Country = Country(name:"Senegal", isoCode:"SN")
    public static let Serbia: Country = Country(name:"Serbia", isoCode:"RS")
    public static let SerbiaAndMontenegro: Country = Country(name:"Serbia and Montenegro", isoCode:"CS")
    public static let Seychelles: Country = Country(name:"Seychelles", isoCode:"SC")
    public static let SierraLeone: Country = Country(name:"Sierra Leone", isoCode:"SL")
    public static let Singapore: Country = Country(name:"Singapore", isoCode:"SG")
    public static let Slovakia: Country = Country(name:"Slovakia", isoCode:"SK")
    public static let Slovenia: Country = Country(name:"Slovenia", isoCode:"SI")
    public static let SolomonIslands: Country = Country(name:"Solomon Islands", isoCode:"SB")
    public static let Somalia: Country = Country(name:"Somalia", isoCode:"SO")
    public static let SouthAfrica: Country = Country(name:"South Africa", isoCode:"ZA")
    public static let SouthGeorgia: Country = Country(name:"South Georgia and the South Sandwich Islands", isoCode:"GS")
    public static let SouthKorea: Country = Country(name:"South Korea", isoCode:"KR")
    public static let Spain: Country = Country(name:"Spain", isoCode:"ES")
    public static let SriLanka: Country = Country(name:"Sri Lanka", isoCode:"LK")
    public static let Sudan: Country = Country(name:"Sudan", isoCode:"SD")
    public static let Suriname: Country = Country(name:"Suriname", isoCode:"SR")
    public static let Svalbard: Country = Country(name:"Svalbard and Jan Mayen", isoCode:"SJ")
    public static let Swaziland: Country = Country(name:"Swaziland", isoCode:"SZ")
    public static let Sweden: Country = Country(name:"Sweden", isoCode:"SE")
    public static let Switzerland: Country = Country(name:"Switzerland", isoCode:"CH")
    public static let Syria: Country = Country(name:"Syria", isoCode:"SY")
    public static let Taiwan: Country = Country(name:"Taiwan", isoCode:"TW")
    public static let Tajikistan: Country = Country(name:"Tajikistan", isoCode:"TJ")
    public static let Tanzania: Country = Country(name:"Tanzania", isoCode:"TZ")
    public static let Thailand: Country = Country(name:"Thailand", isoCode:"TH")
    public static let Togo: Country = Country(name:"Togo", isoCode:"TG")
    public static let Tokelau: Country = Country(name:"Tokelau", isoCode:"TK")
    public static let Tonga: Country = Country(name:"Tonga", isoCode:"TO")
    public static let Trinidad: Country = Country(name:"Trinidad and Tobago", isoCode:"TT")
    public static let Tunisia: Country = Country(name:"Tunisia", isoCode:"TN")
    public static let Turkey: Country = Country(name:"Turkey", isoCode:"TR")
    public static let Turkmenistan: Country = Country(name:"Turkmenistan", isoCode:"TM")
    public static let Turks: Country = Country(name:"Turks and Caicos Islands", isoCode:"TC")
    public static let Tuvalu: Country = Country(name:"Tuvalu", isoCode:"TV")
    public static let Uganda: Country = Country(name:"Uganda", isoCode:"UG")
    public static let Ukraine: Country = Country(name:"Ukraine", isoCode:"UA")
    public static let UnitedArabEmirates: Country = Country(name:"United Arab Emirates", isoCode:"AE")
    public static let Uruguay: Country = Country(name:"Uruguay", isoCode:"UY")
    public static let Uzbekistan: Country = Country(name:"Uzbekistan", isoCode:"UZ")
    public static let Vanuatu: Country = Country(name:"Vanuatu", isoCode:"VU")
    public static let VaticanCity: Country = Country(name:"Vatican City", isoCode:"VA")
    public static let Venezuela: Country = Country(name:"Venezuela", isoCode:"VE")
    public static let Vietnam: Country = Country(name:"Vietnam", isoCode:"VN")
    public static let Wallis: Country = Country(name:"Wallis and Futuna", isoCode:"WF")
    public static let WesternSahara: Country = Country(name:"Western Sahara", isoCode:"EH")
    public static let Yemen: Country = Country(name:"Yemen", isoCode:"YE")
    public static let Zambia: Country = Country(name:"Zambia", isoCode:"ZM")
    public static let Zimbabwe: Country = Country(name:"Zimbabwe", isoCode:"ZW")
    
    public static var allValues = [Countries.DefaultCountry,
                            Countries.UnitedKingdom,
                            Countries.UnitedStates,
                            Countries.Germany,
                            Countries.Afghanistan,
                            Countries.AlandIsland,
                            Countries.Albania,
                            Countries.Algeria,
                            Countries.AmericanSamoa,
                            Countries.Andorra,
                            Countries.Angola,
                            Countries.Anguilla,
                            Countries.Antarctica,
                            Countries.AntiguaAndBarbuda,
                            Countries.Argentina,
                            Countries.Armenia,
                            Countries.Aruba,
                            Countries.AscensionIsland,
                            Countries.Australia,
                            Countries.Austria,
                            Countries.Azerbaijan,
                            Countries.Bahamas,
                            Countries.Bahrain,
                            Countries.Bangladesh,
                            Countries.Barbados,
                            Countries.Belarus,
                            Countries.Belgium,
                            Countries.Belize,
                            Countries.Benin,
                            Countries.Bermuda,
                            Countries.Bhutan,
                            Countries.Bolivia,
                            Countries.BosniaAndHerzegovina,
                            Countries.Botswana,
                            Countries.BouvetIsland,
                            Countries.Brazil,
                            Countries.BritishIndianOceanTerritory,
                            Countries.BritishVirginIslands,
                            Countries.Brunei,
                            Countries.Bulgaria,
                            Countries.BurkinaFaso,
                            Countries.Burundi,
                            Countries.Cambodia,
                            Countries.Cameroon,
                            Countries.Canada,
                            Countries.CanaryIslands,
                            Countries.CapeVerde,
                            Countries.CaymanIslands,
                            Countries.CentralAfricanRepubli,
                            Countries.Chad,
                            Countries.Chile,
                            Countries.China,
                            Countries.ChristmasIsland,
                            Countries.CocosIslands,
                            Countries.Colombia,
                            Countries.Comoros,
                            Countries.CongoBrazzaville,
                            Countries.CongoKinshasa,
                            Countries.CookIslands,
                            Countries.CostaRica,
                            Countries.CoteDIvoire,
                            Countries.Croatia,
                            Countries.Cuba,
                            Countries.Curacao,
                            Countries.Cyprus,
                            Countries.CzechRepublic,
                            Countries.Denmark,
                            Countries.Djibouti,
                            Countries.Dominica,
                            Countries.DominicaRepublic,
                            Countries.Ecuador,
                            Countries.Egypt,
                            Countries.ElSalvador,
                            Countries.EquatorialGuinea,
                            Countries.Eritrea,
                            Countries.Estonia,
                            Countries.Ethiopia,
                            Countries.FalklandIslands,
                            Countries.FaroeIslands,
                            Countries.Fiji,
                            Countries.Finland,
                            Countries.France,
                            Countries.FrenchGuiana,
                            Countries.FrenchPolynesia,
                            Countries.FrenchSouthernTerritories,
                            Countries.Gabon,
                            Countries.Gambia,
                            Countries.Georgia,
                            Countries.Ghana,
                            Countries.Gibraltar,
                            Countries.Greece,
                            Countries.Greenland,
                            Countries.Grenada,
                            Countries.Guadeloupe,
                            Countries.Guam,
                            Countries.Guatemala,
                            Countries.Guernsey,
                            Countries.Guinea,
                            Countries.GuineaBissau,
                            Countries.Guyana,
                            Countries.Haiti,
                            Countries.HeardIsland,
                            Countries.Honduras,
                            Countries.HongKong,
                            Countries.Hungary,
                            Countries.Iceland,
                            Countries.India,
                            Countries.Indonesia,
                            Countries.Iran,
                            Countries.Iraq,
                            Countries.Ireland,
                            Countries.IsleOfMan,
                            Countries.Israel,
                            Countries.Italy,
                            Countries.Jamaica,
                            Countries.Japan,
                            Countries.Jersey,
                            Countries.Jordan,
                            Countries.Kazakhstan,
                            Countries.Kenya,
                            Countries.Kiribati,
                            Countries.Kosovo,
                            Countries.Kuwait,
                            Countries.Kyrgyzstan,
                            Countries.Laos,
                            Countries.Latvia,
                            Countries.Lebanon,
                            Countries.Lesotho,
                            Countries.Liberia,
                            Countries.Libya,
                            Countries.Liechtenstein,
                            Countries.Lithuania,
                            Countries.Luxembourg,
                            Countries.Macau,
                            Countries.Macedonia,
                            Countries.Madagascar,
                            Countries.Malawi,
                            Countries.Malaysia,
                            Countries.Maldives,
                            Countries.Mali,
                            Countries.Malta,
                            Countries.MarshallIslands,
                            Countries.Martinique,
                            Countries.Mauritania,
                            Countries.Mauritius,
                            Countries.Mayotte,
                            Countries.Mexico,
                            Countries.Micronesia,
                            Countries.Moldova,
                            Countries.Monaco,
                            Countries.Mongolia,
                            Countries.Montenegro,
                            Countries.Montserrat,
                            Countries.Morocco,
                            Countries.Mozambique,
                            Countries.Myanmar,
                            Countries.Namibia,
                            Countries.Nauru,
                            Countries.Nepal,
                            Countries.Netherlands,
                            Countries.NetherlandsAntilles,
                            Countries.NewCaledonia,
                            Countries.NewZealand,
                            Countries.Nicaragua,
                            Countries.Niger,
                            Countries.Nigeria,
                            Countries.Niue,
                            Countries.NorfolkIsland,
                            Countries.NorthKorea,
                            Countries.NorthernMarianaIslands,
                            Countries.Norway,
                            Countries.Oman,
                            Countries.Pakistan,
                            Countries.Palau,
                            Countries.PalestinianTerritories,
                            Countries.Panama,
                            Countries.PapuaNewGuinea,
                            Countries.Paraguay,
                            Countries.Peru,
                            Countries.Philippines,
                            Countries.PitcairnIslands,
                            Countries.Poland,
                            Countries.Portugal,
                            Countries.PuertoRico,
                            Countries.Qatar,
                            Countries.Réunion,
                            Countries.Romania,
                            Countries.Russia,
                            Countries.Rwanda,
                            Countries.SaintHelena,
                            Countries.SaintKitts,
                            Countries.SaintLucia,
                            Countries.SaintMartin,
                            Countries.SaintPierre,
                            Countries.SaintVincent,
                            Countries.Samoa,
                            Countries.SanMarino,
                            Countries.SaoTome,
                            Countries.SaudiArabia,
                            Countries.Senegal,
                            Countries.Serbia,
                            Countries.SerbiaAndMontenegro,
                            Countries.Seychelles,
                            Countries.SierraLeone,
                            Countries.Singapore,
                            Countries.Slovakia,
                            Countries.Slovenia,
                            Countries.SolomonIslands,
                            Countries.Somalia,
                            Countries.SouthAfrica,
                            Countries.SouthGeorgia,
                            Countries.SouthKorea,
                            Countries.Spain,
                            Countries.SriLanka,
                            Countries.Sudan,
                            Countries.Suriname,
                            Countries.Svalbard,
                            Countries.Swaziland,
                            Countries.Sweden,
                            Countries.Switzerland,
                            Countries.Syria,
                            Countries.Taiwan,
                            Countries.Tajikistan,
                            Countries.Tanzania,
                            Countries.Thailand,
                            Countries.Togo,
                            Countries.Tokelau,
                            Countries.Tonga,
                            Countries.Trinidad,
                            Countries.Tunisia,
                            Countries.Turkey,
                            Countries.Turkmenistan,
                            Countries.Turks,
                            Countries.Tuvalu,
                            Countries.Uganda,
                            Countries.Ukraine,
                            Countries.UnitedArabEmirates,
                            Countries.Uruguay,
                            Countries.Uzbekistan,
                            Countries.Vanuatu,
                            Countries.VaticanCity,
                            Countries.Venezuela,
                            Countries.Vietnam,
                            Countries.Wallis,
                            Countries.WesternSahara,
                            Countries.Yemen,
                            Countries.Zambia,
                            Countries.Zimbabwe]

}
