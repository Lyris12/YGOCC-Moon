--[[
Dread Bastille - Serenado
Bastiglia dell'Angoscia - Serenato
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),8,2)
	--If this card is Xyz Summoned: You can send 1 other card you control or from your hand to the GY, and if you do, add 1 "Dread Bastille" Spell/Trap from your Deck to your hand.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.XyzSummonedCond,nil,s.thtg,s.thop)
	c:RegisterEffect(e1)
	--During the Main Phase: You can detach 1 material from this card, then target 1 Rock monster in your GY; Special Summon it.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(aux.MainPhaseCond(),aux.DetachSelfCost(),s.sptg,s.spop)
	c:RegisterEffect(e2)
	--[[If this Xyz Summoned card you control is sent to the GY: You can activate this effect; for the rest of the turn after this effect resolves,
	the activation and the effects of "Dread Bastille" Spells cannot be negated.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:HOPT()
	e3:SetFunctions(s.condition,nil,nil,s.operation)
	c:RegisterEffect(e3)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_DREAD_BASTILLE)
end
--E1
function s.tgfilter(c,tp)
	return c:IsAbleToGrave() and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,c)
end
function s.thfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_DREAD_BASTILLE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExists(false,s.tgfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,1,c,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD|LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.ForcedSelect(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,1,1,aux.ExceptThis(e:GetHandler()),tp):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsInGY() then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.Search(g,tp)
		end
	end
end

--E2
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E3
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsPreviousControler(tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
	e1:SetLabel(0)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	e2:SetLabel(1)
	e2:SetValue(s.efilter)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISABLE)
	e3:SetTargetRange(0xff,0xff)
	e3:SetTarget(s.distarget)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
end
function s.efilter(e,ct)
	local te,cid=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_CHAIN_ID)
	local tc=te:GetHandler()
	return (e:GetLabel()==1 or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and te:IsActiveType(TYPE_SPELL) and tc and aux.CheckArchetypeReasonEffect(s,te,ARCHE_DREAD_BASTILLE)
end
function s.distarget(e,c)
	return c:IsSpell() and c:IsSetCard(ARCHE_DREAD_BASTILLE)
end