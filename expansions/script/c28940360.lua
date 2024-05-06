--Hellgate Converguard
local ref,id=GetID()
Duel.LoadScript("Commons_Converguard.lua")
function ref.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	Converguard.EnableConvergence(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(3)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER_E)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:HOPT()
	e1:SetTarget(ref.destg)
	e1:SetOperation(ref.desop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(ref.atktg)
	e2:SetOperation(ref.atkop)
	c:RegisterEffect(e2)
end

--Summon
function ref.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,c:GetLocation())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function ref.pndfilter(c) return Converguard.Is(c) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() end
function ref.desop(e,tp) local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(ref.pndfilter,tp,LOCATION_DECK,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,ref.pndfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.BreakEffect()
		if #g>0 and Duel.SendtoExtraP(g,nil,REASON_EFFECT)~=0 and not tc:IsType(TYPE_PENDULUM) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.SendtoHand(g,nil,REASON_EFFECT) 
			Duel.ConfirmCards(1-tp,g) 
		end
	end
end

--Buff
function ref.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsFaceup() end
	--local g=Duel.GetMatchingGroup(Converguard.Is,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	local val=(Duel.GetMatchingGroupCount(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*400)+800
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,val)
end
function ref.atkop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local val=(Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)*400)+800
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	--[[local g=Duel.GetMatchingGroup(Converguard.Is,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end]]
end
