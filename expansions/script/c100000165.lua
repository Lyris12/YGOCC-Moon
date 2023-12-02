--[[
Diabolical Quarphex LV8
Quarphex Diabolico LV8
Card Author: Xarc
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[You can discard this card; send 1 "Quarphex" card from your Deck to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(nil,s.tgcost,s.tgtg,s.tgop)
	c:RegisterEffect(e1)
	--[[Once per turn (Quick Effect): You can change the Level of all monsters your opponent currently controls to 4 until the end of this turn, then you can banish 1 Level 4 monster on the field.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,nil,s.lvtg,s.lvop)
	c:RegisterEffect(e2)
	--[[Activate only as Chain Link 4 (Quick Effect): Ritual Summon 1 "Diabolical Quarphex LV12" from your hand or Deck by Tributing monsters
	from your hand or either field whose total Levels exactly equal 12, including this card.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_RELEASE|CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetFunctions(s.condition,nil,s.target,s.operation)
	c:RegisterEffect(e3)
end
s.lvup={CARD_DIABOLICAL_QUARPHEX_LV4,CARD_DIABOLICAL_QUARPHEX_LV12}
s.lvdn={CARD_DIABOLICAL_QUARPHEX_LV4}

--E1
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST|REASON_DISCARD)
end
function s.tgfilter(c)
	return c:IsSetCard(ARCHE_QUARPHEX) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsRitualMonster() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR|RACE_DRAGON) and c:IsAbleToHand()
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--E2
function s.lvfilter(c)
	return c:IsFaceup() and c:HasLevel() and not c:IsLevel(4)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.lvfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE)
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsLevel(4) and c:IsAbleToRemove()
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(s.lvfilter,tp,0,LOCATION_MZONE,nil)
	local check=false
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
		if not check and not tc:IsImmuneToEffect(e1) then
			check=true
		end
	end
	local rg=Duel.Group(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #rg>0 and Duel.SelectYesNo(tp,STRING_ASK_BANISH) then
		Duel.HintMessage(tp,HINTMSG_REMOVE)
		local sg=rg:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.HintSelection(sg)
			Duel.BreakEffect()
			Duel.Banish(sg)
		end
	end
end

--E3
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ev==3
end
function s.filter(c)
	return c:IsCode(CARD_DIABOLICAL_QUARPHEX_LV12)
end
function s.oppomat(c,e,tp)
	return not c:IsImmuneToEffect(e) and c:IsFaceup() and c:IsReleasableByEffect() and c:HasLevel() and c:GetLevel()>0
end
function s.fixedlv()
	return 12
end
function s.rcheck(gc)
	return	function(tp,g,c)
				return g:IsContains(gc)
			end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local mg2=Duel.Group(s.oppomat,tp,0,LOCATION_MZONE,nil,e,tp)
		aux.RCheckAdditional=s.rcheck(c)
		local res=mg:IsContains(c) and Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,s.filter,e,tp,mg,mg2,s.fixedlv,"Equal")
		aux.RCheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local c=e:GetHandler()
	local mg=Duel.GetRitualMaterial(tp)
	local mg2=Duel.Group(s.oppomat,tp,0,LOCATION_MZONE,nil,e,tp)
	if not c:IsRelateToChain() or (not mg:IsContains(c) and not mg2:IsContains(c)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	aux.RCheckAdditional=s.rcheck(c)
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,s.filter,e,tp,mg,mg2,s.fixedlv,"Equal")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg2=mg2:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
		mg:RemoveCard(tc)
		end
		if not mg:IsContains(c) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		Duel.SetSelectedCard(c)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,s.fixedlv(),"Equal")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,s.fixedlv(),tp,tc,s.fixedlv(),"Equal")
		aux.GCheckAdditional=nil
		if not mat then
			aux.RCheckAdditional=nil
			goto cancel
		end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	aux.RCheckAdditional=nil
end
