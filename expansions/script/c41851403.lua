--created by Walrus, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetDescription(1131)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e1:SetLabelObject(g)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetDescription(1068)
	e2:SetLabelObject(e1)
	e2:SetCondition(function(e,tp) local ph=Duel.GetCurrentPhase() if Duel.GetTurnPlayer()==tp then return ph==PHASE_MAIN1 or ph==PHASE_MAIN2 else return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE end end)
	e2:SetCost(s.cost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+1000)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetCondition(s.con)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) or re:IsHasCategory(CATEGORY_NEGATE)
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(aux.AND(Card.IsOnField,Card.IsControler),nil,tp)-tg:GetCount()>0
end
function s.cfilter(c,e)
	return c:GetFlagEffect(id)>0 and c:GetEquipTarget()==e:GetHandler() and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local qg=e:GetLabelObject()
	if chk==0 then return qg and qg:IsExists(s.cfilter,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Remove(qg:FilterSelect(tp,s.cfilter,1,1,nil,e),POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.rfilter(c)
	return c:IsSetCard(0x106) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Remove(Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,1,1,nil),POS_FACEUP,REASON_COST)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE):Select(tp,1,1,nil)
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	if not (tc and Duel.Equip(tp,tc,c,false)) then return end
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	e:GetLabelObject():GetLabelObject():AddCard(tc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	tc:RegisterEffect(e1)
	local atk=math.ceil(tc:GetBaseAttack()/2)
	if atk>0 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if re and (not rc or not rc:IsSetCard(0x106)) then rc=re:GetHandler() end
	return rc:IsSetCard(0x106)
end
function s.filter(c)
	return c:IsSetCard(0x106) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		and not c:IsCode(id)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local dg=Group.CreateGroup()
	for dc in aux.Next(Duel.GetFieldGroup(tp,0,LOCATION_MZONE)) do
		local preatk=dc:GetAttack()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		dc:RegisterEffect(e1)
		if preatk>1000 and dc:IsAttackBelow(1000) then dg:AddCard(dc) end
	end
	Duel.Destroy(dg,REASON_EFFECT)
end
