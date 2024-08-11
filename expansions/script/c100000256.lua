--[[
Dread Bastille - Arpeggio
Bastiglia dell'Angoscia - Arpeggio
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),8,2,nil,nil,99)
	--[[If this card is Xyz Summoned: You can send 1 Rock monster from your Deck to your GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.tgtg,
		s.tgop
	)
	c:RegisterEffect(e1)
	--[[(Quick Effect): You can detach 1 material from this card, then target 1 Spell/Trap on the field; destroy it, and if you do, inflict 1000 damage to your opponent.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		nil,
		aux.DetachSelfCost(),
		s.destg,
		s.desop
	)
	c:RegisterEffect(e2)
	--[[If this Xyz Summoned card you control is sent to the GY: You can target 1 "Dread Bastille" Xyz Monster you control; attach this card to it as material,
	then you can attach a number of "Dread Bastille" monsters from your GY to it, up to the number of materials this card had on the field.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:HOPT()
	e3:SetFunctions(
		s.atcon,
		nil,
		s.attg,
		s.atop
	)
	c:RegisterEffect(e3)
end

--E1
function s.tgfilter(c)
	return c:IsMonster() and c:IsRace(RACE_ROCK) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--E2
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsSpellTrapOnField() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end

--E3
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsPreviousControler(tp)
end
function s.atfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_DREAD_BASTILLE)
end
function s.atfilter2(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_DREAD_BASTILLE) and c:IsCanOverlay()
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler() and s.atfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanOverlay(tp) and Duel.IsExists(true,s.atfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Select(HINTMSG_ATTACHTO,true,tp,s.atfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetTargetParam(c:GetPreviousOverlayCountOnField())
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,c,tp,0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and Duel.Attach(c,tc) then
		Duel.AdjustAll()
		if not tc:IsRelateToChain() then return end
		local g=Duel.Group(s.atfilter2,tp,LOCATION_GRAVE,0,nil)
		local ct=Duel.GetTargetParam()
		if #g>0 and ct>0 and Duel.SelectYesNo(tp,STRING_ASK_ATTACH) then
			Duel.HintMessage(tp,HINTMSG_ATTACH)
			local tg=g:Select(tp,1,ct,nil)
			Duel.HintSelection(tg)
			Duel.Attach(tg,tc)
		end
	end
end