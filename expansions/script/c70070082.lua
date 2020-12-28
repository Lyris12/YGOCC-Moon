--Muscwole Knockout
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cid=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cid
end
local id,cid=getID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_BATTLE_START)
	e2:SetRange(LOCATION_GRAVE)
				e2:SetCountLimit(1,id+100)
	e2:SetCondition(cid.drcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cid.drtg)
	e2:SetOperation(cid.drop)
	c:RegisterEffect(e2)
end
function cid.efilter(c)
	return c:IsSetCard(0x777) and c:GetAttack()>=(c:GetBaseAttack()+1400)
end
function cid.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(cid.efilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetCurrentPhase()==PHASE_BATTLE_START and Duel.GetTurnPlayer()==tp
end
function cid.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function cid.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function cid.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x777) and Duel.IsExistingMatchingCard(cid.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
function cid.desfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
function cid.spfilter1(c)
	return c:IsSetCard(0x777) and c:IsFaceup()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(cid.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.SelectTarget(tp,cid.thfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,tp,1)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(cid.spfilter1,tp,LOCATION_MZONE,0,nil)
	local tc=g1:GetFirst()
	while tc do
		--Activate
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		tc=g1:GetNext()
	end
	local tc1=Duel.GetFirstTarget()
	if not tc1:IsRelateToEffect(e) or tc1:IsFacedown() then return end
	local tc2=Duel.SelectMatchingCard(tp,cid.desfilter,tp,0,LOCATION_MZONE,1,1,nil,tc1:GetAttack())
	Duel.Destroy(tc2,REASON_EFFECT)
end
 
