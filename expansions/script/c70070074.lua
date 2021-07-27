--Muscwole Beefmaster
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cid=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cid
end
local id,cid=getID()
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
	--atkup
	local e2=Effect.CreateEffect(c)
	--e1:SetDescription(aux.Stringid(12023931,0))
                e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
                e2:SetCondition(cid.atk(2400))
	e2:SetCountLimit(1)
	e2:SetTarget(cid.bufftg)
	e2:SetOperation(cid.buffop)
	c:RegisterEffect(e2)
	--attack twice
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLED)
	e1:SetRange(LOCATION_MZONE)
	--e1:SetCountLimit(3)
	e1:SetCondition(cid.atkcon)
	--e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x777)
	e1:SetOperation(cid.atkop)
	c:RegisterEffect(e1)
	--remove
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(cid.condition)
	e3:SetTarget(cid.target)
	e3:SetOperation(cid.operation)
	c:RegisterEffect(e3)
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
	if not e:GetHandler():IsAttackAbove(3100) then return false end
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
function cid.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x777)
end
function cid.bufftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(cid.atkfilter,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cid.atkfilter,tp,LOCATION_MZONE,0,1,1,c)
end
function cid.buffop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAttackAbove(3800) end
	local bc=e:GetHandler():GetBattleTarget()
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
