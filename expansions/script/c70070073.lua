--Muscwole Machomaxismo
local cid,id=GetID()
function cid.initial_effect(c)
	--cannot be target
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetValue(cid.efilter)
	c:RegisterEffect(e7)
	--special summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetCountLimit(1,id)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(cid.spcon)
	c:RegisterEffect(e0)
	--attack twice
	--local e1=Effect.CreateEffect(c)
	--e1:SetDescription(aux.Stringid(id,0))
	--e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	--e1:SetCode(EVENT_BATTLED)
	--e1:SetRange(LOCATION_MZONE)
	--e1:SetCountLimit(3)
	--e1:SetCondition(cid.atkcon)
	--e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x777)
	--e1:SetOperation(cid.atkop)
	--c:RegisterEffect(e1)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1000)
	e3:SetCondition(cid.atk(3300))
	e3:SetTarget(cid.destg)
	e3:SetOperation(cid.desop)
	c:RegisterEffect(e3)
	--negate
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+10000)
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetCondition(cid.atk(4000))
	e4:SetTarget(cid.distg)
	e4:SetOperation(cid.disop)
	c:RegisterEffect(e4)
	--destroy replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetCountLimit(1,id+100)
	e5:SetCondition(cid.atk(2600))
	e5:SetTarget(cid.reptg)
	c:RegisterEffect(e5)
end
function cid.repfilter(c,tp,e)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
	 and c:IsReason(REASON_EFFECT)
end
function cid.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(cid.repfilter,1,nil,tp,e) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) and re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re)then
		Duel.Destroy(re:GetHandler(),REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
function cid.efilter(e,re,rp)
	return re:GetHandler():IsType(TYPE_EQUIP) and not re:GetHandler():IsSetCard(0x777)
end
function cid.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function cid.atk(val)--(e3,e4 con)
	return function(e)
		return e:GetHandler():IsAttackAbove(val)
	end
end
function cid.atkcon(e,tp,eg,ep,ev,re,r,rp)
	--return function(e)
	--return e:GetHandler():IsAttackAbove(2300) end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if a:IsStatus(STATUS_OPPO_BATTLE) and d:IsControler(tp) then a,d=d,a end
	if a:IsSetCard(0x777)
		and not a:IsStatus(STATUS_BATTLE_DESTROYED) and d:IsStatus(STATUS_BATTLE_DESTROYED) then
		e:SetLabelObject(a)
		return true
	else return false end
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToBattle() and Duel.GetFlagEffect(tp,id)==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		Duel.RegisterFlagEffect(tp,id,0x1fe0000+RESET_PHASE+PHASE_BATTLE,0,1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		--atkup
		--local e3=e1:Clone()
		--e3:SetCode(EFFECT_UPDATE_ATTACK)
		--e3:SetValue(300)
		--tc:RegisterEffect(e3)
		Duel.SetChainLimit(aux.FALSE)
	end
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function cid.filter(c)
	return not c:IsDisabled() and c:IsFaceup()
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
	end
end
