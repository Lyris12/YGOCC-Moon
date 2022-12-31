--Abyss Actor - Brave Support
--scripted by Rawstone
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--ATKup
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.atkval1)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x10ec))
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(s.cond)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(s.cond)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	--search
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,id+1000)
	e4:SetCost(s.cost)
	e4:SetTarget(s.trg)   
	e4:SetOperation(s.ope)
	c:RegisterEffect(e4)
	local e4x=e4:Clone()
	e4x:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4x)
	--hakai
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCategory(CATEGORY_CONTROL+CATEGORY_ATKCHANGE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.mfield)
	e5:SetOperation(s.chop)
	c:RegisterEffect(e5)
end
	function s.atkval1(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_SZONE,LOCATION_SZONE,nil)*100
end
	function s.confilter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
	function s.cond(e)
	return Duel.IsExistingMatchingCard(s.confilter1,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
	function s.filt(c,tp)
	return c:IsSetCard(0x10ec) and c:IsFaceup() and c:IsAbleToDeckAsCost() and c:IsType(TYPE_PENDULUM)
		and Duel.IsExistingMatchingCard(s.filt2,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
	function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filt,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filt,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetCode())
	Duel.SendtoDeck(g:GetFirst(),nil,2,REASON_COST)
end
	function s.filt2(c,code)
	return c:IsSetCard(0x10ec) and c:IsAbleToHand() and not c:IsCode(code)
end
	function s.trg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
	function s.ope(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filt2,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
	function s.chfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
	function s.gfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsAttackAbove(0)
end
	function s.gfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec)
end
	function s.mfield(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and s.chfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.chfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetMatchingGroupCount(s.gfilter,tp,LOCATION_MZONE,1,e:GetHandler())>=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.chfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local sg=Duel.GetMatchingGroup(s.gfilter,tp,0,LOCATION_MZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
	function s.chop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local a=Duel.GetFirstTarget()
	local preatk=a:GetAttack()
	if a:IsRelateToEffect(e) then
		Duel.GetControl(a,1-tp)
			if Duel.GetControl(a,1-tp) and a:IsRelateToEffect(e) and a:IsFaceup() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(0)
			a:RegisterEffect(e1)
			if a:GetAttack()==0 and Duel.GetMatchingGroupCount(s.gfilter2,tp,LOCATION_MZONE,0,1,nil)>=1 then
				local g=Duel.GetMatchingGroup(s.gfilter2,tp,LOCATION_MZONE,0,1,nil)
				local a1=g:GetFirst()
				while a1 do
					local e2=Effect.CreateEffect(e:GetHandler())
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					e2:SetCode(EFFECT_UPDATE_ATTACK)
					e2:SetValue(preatk)
					a1:RegisterEffect(e2)
					a1=g:GetNext()
				end
			end
		end
	end
end





















