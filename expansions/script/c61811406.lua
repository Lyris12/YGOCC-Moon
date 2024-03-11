--[[
Dread Bastille - Fugue
Bastiglia dell'Angoscia - Fuga
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),8,2,nil,nil,99)
	--If this card is Xyz Summoned: You can send 1 card from your hand or field to the GY, and if you do, add 1 "Dread Bastille" card from your GY to your hand.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.XyzSummonedCond,nil,s.thtg,s.thop)
	c:RegisterEffect(e1)
	--(Quick Effect): You can detach 1 material from this card, then target 1 monster your opponent controls; destroy it, and if you do, inflict damage to your opponent equal to half of the destroyed monster's ATK.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,aux.DetachSelfCost(),s.destg,s.desop)
	c:RegisterEffect(e2)
	--[[If this Xyz Summoned card you control is sent to the GY while you control a "Dread Bastille" monster: You can target 1 "Dread Bastille" monster you control;
	Special Summon this card from your GY, and if you do, attach the targeted card to this card as material.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:HOPT()
	e3:SetFunctions(s.condition,nil,s.target,s.operation)
	c:RegisterEffect(e3)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_DREAD_BASTILLE)
end
--E1
function s.tgfilter(c,tp)
	return c:IsAbleToGrave() and Duel.IsExists(false,s.thfilter,tp,LOCATION_GRAVE,0,1,c)
end
function s.thfilter(c)
	return c:IsSetCard(ARCHE_DREAD_BASTILLE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.tgfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD|LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.ForcedSelect(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsInGY() then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.Search(g,tp)
		end
	end
end

--E2
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then
		return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(g:GetFirst():GetAttack()/2))
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,math.floor(tc:GetAttack()/2),REASON_EFFECT)
	end
end

--E3
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsPreviousControler(tp)
		and Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_DREAD_BASTILLE),tp,LOCATION_MZONE,0,1,nil)
end
function s.matfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DREAD_BASTILLE) and c:IsCanOverlay(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.matfilter(chkc,tp) end
	if chk==0 then return c:IsType(TYPE_XYZ) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_XYZ)
		and tc:IsRelateToChain() and tc:IsCanOverlay(c:GetControler()) and not tc:IsImmuneToEffect(e) then
		Duel.Attach(tc,c)
	end
end