--HDD Plutia, Iris Heart
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,68709343,aux.FilterBoolFunction(Card.IsFusionSetCard,0xf08),1,true,true)
	aux.AddContactFusionProcedure(c,cid.cfilter,LOCATION_ONFIELD,0,aux.tdcfop(c))
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(cid.splimit)
	c:RegisterEffect(e1)
	--stats
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(cid.target)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2x)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(cid.discon)
	e3:SetCost(cid.discost)
	e3:SetTarget(cid.distg)
	e3:SetOperation(cid.disop)
	c:RegisterEffect(e3)
end
--Filters
function cid.cfilter(c)
	return (c:IsFusionCode(68709343) or c:IsFusionSetCard(0xf08) and c:IsType(TYPE_MONSTER))
		and c:IsAbleToDeckOrExtraAsCost()
end
--SPSUMMON CONDITION
function cid.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
--stats
function cid.token(c)
	return c:IsFaceup() and c:IsCode(68709350)
end
function cid.target(e,c)
	return Duel.IsExistingMatchingCard(cid.token,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
--NEGATE
function cid.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function cid.rmfilter(c,tp,code)
	return c:IsSetCard(0xf08,0xf09) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and ((code~=0 and not c:IsCode(code)) or (code==0 and Duel.IsExistingMatchingCard(cid.rmfilter,tp,LOCATION_GRAVE,0,1,c,tp,c:GetCode())))
end
function cid.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,cid.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp,0)
	if #g1<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,cid.rmfilter,tp,LOCATION_GRAVE,0,1,1,g1,tp,g1:GetFirst():GetCode())
	if #g2<=0 then return end
	g1:Merge(g2)
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoGrave(eg,REASON_EFFECT)
	end
end