--Paintress EX: Coupé-out Matissa
local cid,id=GetID()
function cid.initial_effect(c)
	 aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,7,cid.filter1,1,1,aux.TRUE,1)  
   --remove
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(500316141,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	--e1:SetHintTiming(0,0x11e0)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
--Negate
	--  local e2=Effect.CreateEffect(c)
	--   e2:SetDescription(aux.Stringid(500316141,0))
	--   e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	--   e2:SetType(EFFECT_TYPE_QUICK_O)
	--  e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	--  e2:SetCode(EVENT_CHAINING)
	--  e2:SetRange(LOCATION_MZONE)
	---  e2:SetCountLimit(1,500316141)
	-- e2:SetCost(cid.cost2)
	--  e2:SetCondition(cid.condition2)
	-- e2:SetTarget(cid.target2)
	--  e2:SetOperation(cid.operation2)
	-- c:RegisterEffect(e2)
   --atkdown
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(10000020,1))
	e8:SetCategory(CATEGORY_ATKCHANGE)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	e8:SetCondition(cid.atkcon)
	e8:SetCost(cid.cost2)
	e8:SetTarget(cid.atktg)
	e8:SetOperation(cid.atkop)
	c:RegisterEffect(e8)
end
function cid.filter3(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsRace(RACE_FAIRY)
end

function cid.costfilter(c)
	return c:IsAbleToRemoveAsCost() and (c:IsType(TYPE_PENDULUM) and c:IsFaceup())
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) and Duel.IsExistingMatchingCard(cid.costfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.costfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
	c:RegisterFlagEffect(500316141,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function cid.filterxx(c,ec,tp)
	return c:IsType(TYPE_EFFECT) and c:IsAbleToRemove()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetControler()~=tp and chkc:GetLocation()==LOCATION_GRAVE and cid.filterxx(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filterxx,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,cid.filterxx,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
  local c=e:GetHandler()	   
  if not (c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) ~=0) then return end
	local atk=tc:GetTextAttack()/2
	local def=tc:GetTextDefense()/2
	if atk>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	end
end


function cid.filter1(c,ec,tp)
	return c:IsRace(RACE_FAIRY) or c:IsAttribute(ATTRIBUTE_LIGHT)
end
function cid.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return  Duel.IsExistingMatchingCard(cid.costfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.costfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	c:RegisterFlagEffect(500316141,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function cid.atkfilter(c,e,tp)
	return c:IsControler(tp) and c:IsPosition(POS_FACEUP_ATTACK) and (not e or c:IsRelateToEffect(e))
end
function cid.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.atkfilter,1,nil,nil,1-tp)
end
function cid.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(cid.atkfilter,nil,e,1-tp)
	local dg=Group.CreateGroup()
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		local preatk=tc:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if preatk~=0 and tc:IsAttack(0) then dg:AddCard(tc) end
		tc=g:GetNext()
	end
	Duel.Destroy(dg,REASON_EFFECT)
end

--function cid.condition2(e,tp,eg,ep,ev,re,r,rp)
	--   return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
	----		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
	--end
	--function cid.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	--  if chk==0 then return true end
	--   Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	--end
	--function cid.operation2(e,tp,eg,ep,ev,re,r,rp)
	--   Duel.NegateActivation(ev)
	--   end