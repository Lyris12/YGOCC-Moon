--Dorein Cupa Mietitrice
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--splimit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--special summon
	local e0x=Effect.CreateEffect(c)
	e0x:SetDescription(aux.Stringid(id,4))
	e0x:SetType(EFFECT_TYPE_FIELD)
	e0x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0x:SetCode(EFFECT_SPSUMMON_PROC)
	e0x:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e0x:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e0x:SetCondition(s.sprcon)
	e0x:SetOperation(s.sprop)
	c:RegisterEffect(e0x)
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.damcon)
	e1:SetCost(s.damcost)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--summon damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(s.damcon2)
	e3:SetCost(s.damcost)
	e3:SetTarget(s.damtg2)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	local e3x=e3:Clone()
	e3x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3x)
	--banish S/T
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.rmcon)
	e4:SetCost(s.damcost_flag(id))
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	local e4x=e4:Clone()
	e4x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4x)
	---banish monster
	local e5=e3:Clone()
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.rmcon2)
	e5:SetCost(s.damcost_flag(id+100))
	e5:SetTarget(s.rmtg2)
	e5:SetOperation(s.rmop2)
	c:RegisterEffect(e5)
	local e5x=e5:Clone()
	e5x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5x)
	--count damage
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
function s.chainfilter(re,tp,cid)
	return re:GetHandler():IsSetCard(0xd04) or not re:IsHasCategory(CATEGORY_DAMAGE)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-ep then
		s[rp]=s[rp]+ev
	end
end
function s.damchk(val)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if not tp then tp=e:GetHandlerPlayer() end
				return s[tp]>=val
			end
end

function s.sprfilter(c)
	return c:IsSetCard(0xd04) and c:IsAbleToRemoveAsCost()
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_GRAVE,0,3,c)
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.sprfilter,tp,LOCATION_GRAVE,0,3,3,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(1-tp)>=3000
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.damcost_flag(flag)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return s.damcost(e,tp,eg,ep,ev,re,r,rp,0) end
				s.damcost(e,tp,eg,ep,ev,re,r,rp,1)
				e:GetHandler():RegisterFlagEffect(flag,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			end
end
function s.aclimit(e,re,tp)
	return not s.chainfilter(re,tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLP(1-tp)<3000 then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.cf(c)
	return c:IsFaceup() and c:IsSetCard(0xd04) and c:IsType(TYPE_MONSTER)
end
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(1-tp)>=3000 and s.damchk(1000)(e,tp) and not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cf,1,nil)
end
function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return s.damchk(2000)(e,tp) and not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cf,1,nil) and not e:GetHandler():HasFlagEffect(id)
end
function s.rmfilter(c)
	return c:IsType(TYPE_ST) and (c:IsFaceup() or c:IsLocation(LOCATION_SZONE)) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end

function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	return s.damchk(3000)(e,tp) and not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cf,1,nil) and not e:GetHandler():HasFlagEffect(id+100)
end
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end