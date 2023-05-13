--Ascension du Vaisseau
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_CHEVALIER_DU_VAISSEAU)
	--[[This card can be used to Ritual Summon any face-up Insect Ritual Monster from your Extra Deck.
	You must also Tribute monsters from your hand or field whose total Levels equal or exceed the Level of the Ritual Monster you Ritual Summon.
	If you Ritual Summon a "Vaisseau" Ritual Monster, you can add 1 "Chevalier du Vaisseau" from your Deck to your Extra Deck, face-up, as the entire requirement, instead.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetTarget(s.RitualUltimateTarget(s.filter,Card.GetLevel,"Greater",LOCATION_EXTRA))
	e1:SetOperation(s.RitualUltimateOperation(s.filter,Card.GetLevel,"Greater",LOCATION_EXTRA))
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
function s.tefilter(c)
	return c:IsCode(CARD_CHEVALIER_DU_VAISSEAU) and c:IsMonster(TYPE_PENDULUM) and not c:IsForbidden()
end

function s.RitualCheck(g,tp,c,lv,greater_or_equal)
	if not (Duel.GetMZoneCount(tp,g,tp)>0 and (not c.mat_group_check or c.mat_group_check(g,tp)) and (not Auxiliary.RCheckAdditional or Auxiliary.RCheckAdditional(tp,g,c))) then return false end
	if c:IsSetCard(ARCHE_VAISSEAU) and #g==1 then
		local tc=g:GetFirst()
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(tp) and s.tefilter(tc)
	else
		return Auxiliary["RitualCheck"..greater_or_equal](g,c,lv) and g:FilterCount(aux.PLChk,nil,tp,LOCATION_DECK)==0
	end
end
function s.RitualUltimateFilter(c,filter,e,tp,m1,m2,level_function,greater_or_equal,chk)
	if bit.band(c:GetType(),0x81)~=0x81 or (filter and not filter(c,e,tp,chk)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local lv=level_function(c)
	Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(c,lv,greater_or_equal)
	local res=mg:CheckSubGroup(s.RitualCheck,1,lv,tp,c,lv,greater_or_equal)
	Auxiliary.GCheckAdditional=nil
	return res
end
function s.RitualUltimateTarget(filter,level_function,greater_or_equal,summon_location)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp)
					local exg=Duel.GetMatchingGroup(s.tefilter,tp,LOCATION_DECK,0,nil)
					return Duel.IsExistingMatchingCard(s.RitualUltimateFilter,tp,summon_location,0,1,nil,filter,e,tp,mg,exg,level_function,greater_or_equal,true)
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,summon_location)
			end
end
function s.RitualUltimateOperation(filter,level_function,greater_or_equal,summon_location)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				::RitualUltimateSelectStart::
				local mg=Duel.GetRitualMaterial(tp)
				local exg=Duel.GetMatchingGroup(s.tefilter,tp,LOCATION_DECK,0,nil)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.RitualUltimateFilter),tp,summon_location,0,1,1,nil,filter,e,tp,mg,exg,level_function,greater_or_equal)
				local tc=tg:GetFirst()
				local mat
				if tc then
					mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
					if exg then
						mg:Merge(exg)
					end
					if tc.mat_filter then
						mg=mg:Filter(tc.mat_filter,tc,tp)
					else
						mg:RemoveCard(tc)
					end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
					local lv=level_function(tc)
					Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(tc,lv,greater_or_equal)
					mat=mg:SelectSubGroup(tp,s.RitualCheck,true,1,lv,tp,tc,lv,greater_or_equal)
					Auxiliary.GCheckAdditional=nil
					if not mat then goto RitualUltimateSelectStart end
					tc:SetMaterial(mat)
					if #mat==1 then
						local mc=mat:GetFirst()
						if mc:IsLocation(LOCATION_DECK) and mc:IsControler(tp) and s.tefilter(mc) then
							Duel.SendtoExtraP(mc,nil,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
						else
							Duel.ReleaseRitualMaterial(mat)
						end
					else
						Duel.ReleaseRitualMaterial(mat)
					end
					Duel.BreakEffect()
					Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
					tc:CompleteProcedure()
				end
			end
end