resource ResMay = ParamMay ** open Prelude, Predef in {

--------------------------------------------------------------------------------
-- Nouns
oper

  Noun : Type = {
    s : NForm => Str
    } ;
  Noun2 : Type = Noun ** {c2 : Preposition} ;
  Noun3 : Type = Noun2 ** {c3 : Preposition} ;

  CNoun : Type = Noun ** {
    heavyMod : Str ; -- heavy stuff like relative clauses after determiner
    } ;
  linCN : CNoun -> Str = \cn -> cn.s ! NF Sg Bare ++ cn.heavyMod ;

  PNoun : Type = Noun ;

  mkNoun : Str -> Noun = \anjing -> {
    s = table {
      NF Sg p => anjing + ParamMay.poss2str p ;
      NF Pl p => duplicate anjing + ParamMay.poss2str p
      }
    } ;

  useN : Noun -> CNoun = \n -> n ** {
    heavyMod = []
    } ;

---------------------------------------------
-- Pronoun

  Pronoun : Type = {
    s : Str ;
    p : Person ; -- for relative clauses
    empty : Str ; -- need to avoid GF being silly. See https://inariksit.github.io/gf/2018/08/28/gf-gotchas.html#metavariables-or-those-question-marks-that-appear-when-parsing
    } ;

  mkPron : Str -> Person -> Pronoun = \str,p -> {
    s = str ;
    p = p ;
    empty = []
    } ;
---------------------------------------------
-- NP

  NounPhrase : Type = {
    s : Possession => Str ; -- maybe need to keep +nya etc. open for becoming possessed? TODO check
    a : NPAgr ; -- NP can be made out of nouns and pronouns, need to retain its origin
    empty : Str ; -- need to avoid GF being silly. See https://inariksit.github.io/gf/2018/08/28/gf-gotchas.html#metavariables-or-those-question-marks-that-appear-when-parsing
    } ;

  IPhrase : Type = NounPhrase ** {
    sp : NForm => Str ; -- standalone berapa banyak kucing
  } ;

  emptyNP : NounPhrase = {
    s = \\_ => [] ;
    a = NotPron ;
    empty = []
    } ;

  mkNounPhrase : Str -> NounPhrase = \str -> {
    s = \\_ => str ;
    a = NotPron ;
    empty = []
    } ;

  mkIP : Str -> IPhrase = \str -> {
    s = \\_ => str ;
    a = NotPron ;
    empty = [] ;
    sp = \\_ => str ;
  } ;


--------------------------------------------------------------------------------
-- Det, Quant, Card, Ord

  Quant : Type = {
    s : Str ; -- quantifier in a context, eg. 'berapa (kucing)'
    sp : NForm => Str ; -- a standalone, eg. '(kucing) berapa banyak'
    poss : Possession ;
    } ;

  IQuant : Type = Quant ** {
    isPre : Bool ;
  } ;

  linDet : Determiner -> Str = \det -> det.pr ++ det.s ;

-- add field in determiner for kedua-dua numbers

  Determiner : Type = Quant ** {
    pr : Str ; -- prefix for numbers
    n : NumType ; -- number as in 5 (noun in singular), Sg or Pl
    count: Str ;
    } ;

  CardNum : Type = {
    s : Str ;
    } ;

  Num : Type = CardNum ** {
    n : NumType
    } ;

  baseNum : Num = {
    s = [] ;
    n = NoNum Sg
    } ;

  CardOrdNum : Type = CardNum ** {
    ord : Str
    } ;

  DigNum : Type = {
    s : CardOrd => Str ;
    } ;

  baseQuant : Quant = {
    s = [] ;
    sp = \\_ => [] ;
    poss = Bare ;
    } ;

      -- \\vf,pol, =>
      -- let
      --   verb   : Str    = joinVP vp tense ant pol agr ;
      --   obj    : Str    = vp.s2 ! agr ;
      -- in case ord of {
      --   ODir   => subj ++ verb ++ obj ;  -- Ġanni jiekol ħut
      --   OQuest => verb ++ obj ++ subj    -- jiekol ħut Ġanni ?
      -- }

  mkQuant : Str -> Quant = \str -> baseQuant ** {
    s = str ;
    sp = \\_ => str
    } ;

  mkDet : Str -> Str -> Number -> Determiner = \cnt, str, num -> mkQuant str ** {
    pr = "" ;
    n = NoNum num ;
    count = "" ;
  } ;

  mkIdet : Str -> Str -> Str -> Number -> Bool -> Determiner = \cnt, str, standalone, num, isPre -> mkDet cnt str num ** {
    pr = case isPre of {True => str ; False => [] } ;
    -- if isPre is True, then: "berapa kucing"
    s = case isPre of { False => str ; True => [] };
    count = cnt ;
    sp = \\_ => standalone ;
  } ;


  --   s = \\p,a => vp.topic ++ np ++ vp.prePart ++ useVerb vp.verb ! p ! a ++ vp.compl ++ compl ;
  -- np = vp.topic ++ np ;
  -- vp = insertObj (ss compl) vp ;

--------------------------------------------------------------------------------
-- Prepositions

  Preposition : Type = {
    s : Str ;             -- dengan
    obj : Person => Str ; -- dengan+nya -- needed in relative clauses to refer to the object
    prepType : PrepType ; -- TODO rename, the name is confusing
    } ;

  mkPrep : Str -> Preposition = \dengan -> {
    s = dengan ;
    obj = \\p => dengan + poss2str (Poss p) ;
    prepType = OtherPrep ;
    } ;

  -- direct object: "hits him" -> "memukul+nya"
  dirPrep : Preposition = {
    s = [] ;
    obj = table {
      P1 => BIND ++ "ku" ;
      P2 => BIND ++ "mu" ;
      P3 => BIND ++ "nya" } ;
    prepType = DirObj ;
    } ;

  -- truly empty
  emptyPrep : Preposition = {
    s = [] ;
    obj = \\_ => [] ;
    prepType = EmptyPrep ;
    } ;

  datPrep : Preposition = mkPrep "kepada" ;

  applyPrep : Preposition -> NounPhrase -> Str = \prep,np ->
    case <np.a, prep.prepType> of {
      <IsPron p,OtherPrep> => prep.obj ! p ++ np.empty ;
      _                    => prep.s ++ np.s ! Bare
    } ;

--------------------------------------------------------------------------------
-- Adjectives

  Adjective : Type = SS ;
  Adjective2 : Type = Adjective ;

  mkAdj : Str -> Adjective = \str -> {s = str} ;

  AdjPhrase = {
    s : Str
    } ; -- ** {compar : Str} ;
--------------------------------------------------------------------------------
-- Verbs

  Verb : Type = {
    s : VForm => Str
    } ;
  Verb2 : Type = Verb ** {
    c2 : Preposition ;
    } ;

  Verb3 : Type = Verb2 ** {
    c3 : Preposition
    } ;

  Verb4 : Type = Verb ** {
    c2 : Preposition ;
    } ;

--  VV : Type = Verb ** {vvtype : VVForm} ;

  regVerb : Str -> Prefix -> Verb = \str,p ->
    mkVerb str (prefix p str) ("di" + str) (str ++ BIND ++ "kan") ;

  mkVerb : (makan, memakan, dimakan, makankan : Str) -> Verb = \rt,act,pass,imp -> {
    s = table {
      Root => rt ;
      Active => act ;
      Passive => pass ;
      Imperative => imp
      }
    } ;

  mkVerb2 : Verb -> Preposition -> Verb2 = \v,pr -> v ** {
    c2 = pr ;
    } ;

  mkVerb3 : Verb -> (p,q : Preposition) -> Verb3 = \v,p,q ->
    mkVerb2 v p ** {c3 = q} ;

  mkVerb4 : Verb -> Preposition -> Str -> Verb4 = \v,pr,str -> v ** {
    s = \\_ => v.s ! Active ++ str;
    c2 = pr ;
    -- passive = "di" ++ BIND ++ v.s ! Root ++ str
    } ;

  copula : Verb = {s = \\_ => "ada"} ; -- TODO

  -- insertObjc : (Agr => Str) -> SlashVP -> SlashVP = \obj,vp ->
  -- insertObj obj vp ** {c2 = vp.c2 ; gapInMiddle = vp.gapInMiddle ; missingAdv = vp.missingAdv } ;
  insertObj : Str -> VerbPhrase -> VerbPhrase = \str,vp -> vp ** {
    s = \\vf,pol => str ++ vp.s ! Active ! Pos ;
    } ;

  insertComp : AdjPhrase -> VerbPhrase -> VerbPhrase = \ap,vp -> vp ** {
  s = \\vf,pol => vp.s ! Active ! Pos ++ ap.s ;
  } ;
------------------
-- Adv

  Adverb : Type = {
    s : Str;
  } ;

  IAdv : Type = Adverb ** {
    isPre : Bool ;
    vf : VForm ;
  } ;

------------------
-- VP

  VerbPhrase : Type = {
    s : VForm => Polarity => Str ; -- tidak or bukan
    } ;

  VPSlash : Type = VerbPhrase ** {
    c2 : Preposition ;
    adjCompl : Str ;
    } ;

  useV : Verb -> VerbPhrase = \v -> v ** {
    s = \\vf,pol => verbneg pol ++ v.s ! vf
    } ;
  
  useComp : Str -> VerbPhrase = \s -> {
    s = \\vf,pol => verbneg pol ++ s ;
    } ;
  useCompN : Str -> VerbPhrase = \s -> {
    s = \\vf,pol => nounneg pol ++ s ;
    } ;

  linVP : VerbPhrase -> Str = \vp -> vp.s ! Active ! Pos;

-- https://www.reddit.com/r/indonesian/comments/gsizsv/when_to_use_tidak_bukan_jangan_belum/

  verbneg : Polarity -> Str = \pol -> case pol of {
    Neg => "tidak" ; -- or "tak"?
    Pos => []
    } ;

  nounneg : Polarity -> Str = \pol -> case pol of {
    Neg => "bukan" ;
    Pos => []
    } ;

  impneg : Polarity -> Str = \pol -> case pol of {
    Neg => "jangan" ;
    Pos => []
  } ;
--------------------------------------------------------------------------------
-- Cl, S

  Clause : Type = {
    subj : Str ;
    pred : VForm => Polarity => Str -- Cl may become relative clause, need to keep open VForm
    } ;

  linCl : Clause -> Str = \cl -> cl.subj ++ cl.pred ! Active ! Pos ;

  RClause : Type = {
    subj : Str ;
    pred : Person => Polarity => Str
    } ;

  linRCl : RClause -> Str = \cl -> cl.subj ++ cl.pred ! P1 ! Pos ;

  RS : Type = {s : Person => Str} ;

  ClSlash : Type = Clause ** {c2 : Preposition} ;
  linClSlash : ClSlash -> Str = \cl -> cl.subj ++ cl.pred ! Root ! Pos ++ cl.c2.s ;

  Sentence : Type = {s : Str} ;


  predVP : NounPhrase -> VerbPhrase -> Clause = \np,vp -> {
    subj = np.s ! Bare ;
    pred = vp.s
    } ;

  predVPSlash : NounPhrase -> VPSlash -> ClSlash = \np,vps ->
    predVP np <vps : VerbPhrase> ** {c2 = vps.c2} ;

  linS : Sentence -> Str = \sent -> sent.s ;


  -- mkClause : Str -> NounPhrase -> VPSlash -> Clause = \str,np,vp -> {
  --   subj = str ++ np.s ! Bare;
  --   pred = vp.s
  -- } ;


  -- mkClause : Str -> IPhrase -> VerbPhrase -> Clause = \str,ip,vp -> {
  --   subj = ip.s ! Bare ;
  --   pred = vp.s ;
  -- } ;


  -- baseQuant : Quant = {
  --   s = [] ;
  --   sp = \\_ => [] ;
  --   poss = Bare ;
  --   } ;

  --     -- \\vf,pol, =>
  --     -- let
  --     --   verb   : Str    = joinVP vp tense ant pol agr ;
  --     --   obj    : Str    = vp.s2 ! agr ;
  --     -- in case ord of {
  --     --   ODir   => subj ++ verb ++ obj ;  -- Ġanni jiekol ħut
  --     --   OQuest => verb ++ obj ++ subj    -- jiekol ħut Ġanni ?
  --     -- }

  -- mkQuant : Str -> Quant = \str -> baseQuant ** {
  --   s = str ;
  --   sp = \\_ => str
  --   } ;

--------------------------------------------------------------------------------
-- linrefs

}
