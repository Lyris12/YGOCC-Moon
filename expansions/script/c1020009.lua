--Coded-Eyes Warfare Dragon
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,s.ffilter,function(g) return g:IsExists(Card.IsSetCard,1,nil,0x2ded) end,2,2)
	--attach
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18897163,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.xyzcon)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35770983,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetCost(s.atkcost)
	e3:SetOperation(s.atkop)
	e2:SetCountLimit(1,id+100+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e3)
end
function s.ffilter(c,xyzc)
	return c:IsSetCard(0xded) and c:IsXyzLevel(xyzc,7)
end
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xded) and c:IsCanOverlay()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.xyzfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then Duel.Overlay(c,g) end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xded)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,e:GetHandler())
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,ct,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a or not d then return false end
	if a:IsControler(1-tp) then a,d=d,a end
	return a~=e:GetHandler() and a:IsFaceup() and a:IsSetCard(0xded) and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a or not d then return end
	if a:IsControler(1-tp) then a,d=d,a end
	if a:IsFaceup() and a:IsSetCard(0xded) and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle() then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(math.ceil(a:GetAttack()/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		a:RegisterEffect(e2)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
	end
end
