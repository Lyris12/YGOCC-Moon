--Lotus Blade Arte - Shinkage
--Commissioned by: Leon Duvall
--Scripted by: Remnance and Senpaizuri3
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.condition)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetCondition(cid.handcon)
	c:RegisterEffect(e2)
	--set
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+17)
	e3:SetCondition(cid.setcon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(cid.settg)
	e3:SetOperation(cid.setop)
	c:RegisterEffect(e3)
end
--filters
function cid.cfilter1(c,tp)
	return c:GetSummonPlayer()==1-tp and c:IsFaceup()
end
function cid.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x3ff)
end
function cid.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3ff) and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function cid.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3ff)
end
function cid.cfilter3(c,tp)
	return c:IsSetCard(0x3ff) and c:IsControler(tp)
end
function cid.cfilter4(c)
	return c:IsFaceup() and c:IsSetCard(0x3ff) and c:IsType(TYPE_SPELL)
end
function cid.setfilter(c)
	return c:IsSetCard(0x3ff) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
--Activate
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg and #eg==1 and eg:IsExists(cid.cfilter1,1,nil,tp)
		and Duel.IsExistingMatchingCard(cid.cfilter2,tp,LOCATION_ONFIELD,0,2,nil)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.costfilter,tp,LOCATION_SZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cid.costfilter,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	if tc:IsFaceup() and not tc:IsDisabled() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		Duel.AdjustInstantly()
		if not tc:IsDisabled() then return end
		for tc in aux.Next(Duel.GetMatchingGroup(cid.atkfilter,tp,LOCATION_MZONE,0,nil)) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(1000)
			tc:RegisterEffect(e1)
		end
	end
end
--act in hand
function cid.handcon(e)
	return Duel.IsExistingMatchingCard(cid.cfilter2,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--set
function cid.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.cfilter3,1,nil,tp) and Duel.IsExistingMatchingCard(cid.cfilter4,tp,LOCATION_ONFIELD,0,1,nil)
end
function cid.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function cid.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,cid.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
		Duel.ConfirmCards(1-tp,g)
	end
end