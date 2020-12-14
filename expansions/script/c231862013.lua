--created by ZEN, coded by TaxingCorn117 & Lyris
local s,id=GetID()
function s.initial_effect(c)
	aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.imtg)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.dmop)
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCategory(CATEGORY_DICE+CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id)>0 end)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCategory(CATEGORY_DAMAGE+CATEGORY_TODECK)
	e4:SetCondition(function(e) return aux.exccon(e) and e:GetHandler():GetFlagEffect(id)>0 end)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
function s.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x52f)
end
function s.imtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(0x52f)
end
function s.efilter(e,te)
	local ex=Duel.GetOperationInfo(Duel.GetCurrentChain(),CATEGORY_DESTROY)
	return te:GetOwner()~=e:GetOwner() and ex
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetControler()==ep then e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1) end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,200)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.TossDice(tp,1)*200
	if Duel.Damage(tp,dc,REASON_EFFECT)==0 or Duel.GetLP(tp)<=0 then return end
	Duel.BreakEffect()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-dc*2)
		tc:RegisterEffect(e1)
	end
end
function s.filter(c)
	return c:IsSetCard(0x52f) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,2,c) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,3,tp,LOCATION_GRAVE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Damage(tp,1000,REASON_EFFECT)==0 or Duel.GetLP(tp)<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsAbleToDeck() then return end
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,2,2,c)
	if #g==2 then
		Duel.HintSelection(g)
		Duel.BreakEffect()
		Duel.SendtoDeck(g+c,nil,2,REASON_EFFECT)
	end
end
