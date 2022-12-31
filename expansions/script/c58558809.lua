--Flibbertysquiggitybiggityboobitygoo
local cid,id=GetID()
function cid.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW+CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(cid.condition)
    e1:SetTarget(cid.target)
    e1:SetOperation(cid.activate)
    c:RegisterEffect(e1)
    --send replace
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SEND_REPLACE)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCondition(cid.con)
    e2:SetTarget(cid.destg)
    e2:SetOperation(cid.repop)
    e2:SetValue(cid.repval)
    Duel.RegisterEffect(e2,0)
	--act in set turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCondition(cid.actcon)
	c:RegisterEffect(e3)
	if not cid.global_check then
		cid.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(cid.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function cid.actcon(e)
	return e:GetHandler():GetFlagEffect(id)>0
end
function cid.con(e,tp,eg,ep,ev,re,r,rp)
    return e:GetOwner():IsFacedown() and e:GetOwner():IsLocation(LOCATION_SZONE)
        and Duel.GetFlagEffect(e:GetOwner():GetControler(),id)==0
end
function cid.repfilter(c,tp)
    return c:IsFacedown() and c:IsControler(tp) and c:IsReason(REASON_EFFECT)
		and c:IsLocation(LOCATION_ONFIELD) and c:GetDestination()==LOCATION_GRAVE
end
function cid.repval(e,c)
    return cid.repfilter(c,e:GetOwner():GetControler())
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local tp=e:GetOwner():GetControler()
    if chk==0 then return e:GetOwner():IsAbleToGraveAsCost() and eg:IsExists(cid.repfilter,1,e:GetOwner(),tp) end
    if Duel.SelectEffectYesNo(tp,e:GetOwner(),96) then
        Duel.RegisterFlagEffect(tp,id,0,0,1)
        return true
    else return false end
end
function cid.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoGrave(e:GetOwner(),REASON_EFFECT)
    Duel.ResetFlagEffect(e:GetOwner():GetControler(),id)
end
function cid.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x5855)
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if g:GetCount()>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
        sg=Duel.GetOperatedGroup()
        local d1=0
        local d2=0
        local tc=sg:GetFirst()
        while tc do
            if tc then
                if tc:IsPreviousControler(0) then d1=d1+1
                else d2=d2+1 end
            end
            tc=sg:GetNext()
        end
        Duel.Draw(0,d1,REASON_EFFECT)
        Duel.Draw(1,d2,REASON_EFFECT)
    end
end
function cid.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re:GetHandler():IsSetCard(0x5855) then return end
	local tc=eg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end