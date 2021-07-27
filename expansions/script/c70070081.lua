--Muscwole Muscplosion
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
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--Negate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_GRAVE)
                e2:SetCountLimit(1,id+100)
	e2:SetCondition(cid.negcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cid.negtg)
	e2:SetOperation(cid.negop)
	c:RegisterEffect(e2)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingTarget(cid.thfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cid.spfilter1,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		--Activate
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
function cid.spfilter1(c)
	return c:IsSetCard(0x777) and c:IsFaceup()
end
function cid.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and rp==1-tp and Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(cid.spfilter1,tp,LOCATION_MZONE,0,1,nil)
end
function cid.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	--if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		--Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	--end
end
function cid.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetTargetRange(0,1)
        e1:SetReset(RESET_PHASE+PHASE_END,2)
        e1:SetLabel(re:GetHandler():GetCode())
        e1:SetValue(cid.aclimit)
        Duel.RegisterEffect(e1,tp)
    end
end
function cid.aclimit(e,re,tp)
    return re:GetHandler():GetOriginalCode()==e:GetLabel()
end
