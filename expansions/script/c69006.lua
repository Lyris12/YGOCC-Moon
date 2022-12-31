--Peach Beach Dreamer, Hanna
function c69006.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(69006,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_IGNITION)
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_PHASE+PHASE_MAIN1)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(c69006.reccon)
    e1:SetCost(c69006.reccost)
    e1:SetTarget(c69006.rectg)
    e1:SetOperation(c69006.recop)
    c:RegisterEffect(e1)
    --summon limit
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_LIMIT_SUMMON_PROC)
    e2:SetCondition(c69006.sumcon)
    c:RegisterEffect(e2)
    --material
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(69006,0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e3:SetTarget(c69006.mattg)
    e3:SetCountLimit(1,69006)
    e3:SetOperation(c69006.matop)
    c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(69006,0))
    e4:SetCategory(CATEGORY_RECOVER)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_SUMMON_SUCCESS)
    e4:SetTarget(c69006.rectg2)
    e4:SetOperation(c69006.recop2)
    c:RegisterEffect(e4)
end
function c69006.reccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c69006.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsPublic() end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_PUBLIC)
    e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
    e:GetHandler():RegisterEffect(e1)
    end
function c69006.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(500)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function c69006.recop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Recover(p,d,REASON_EFFECT)
end
function c69006.sumcon(e,c,minc)
    if not c then return true end
    if not e:GetHandler():IsPublic() then return true else return false end
end
	
function c69006.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6969) and c:IsType(TYPE_XYZ)
end
function c69006.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_HAND) and chkc:IsControler(tp) and c69006.matfilter(chkc) end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		and Duel.IsExistingTarget(c69006.matfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c69006.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c69006.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
function c69006.revealed(c)
    return c:IsSetCard(0x6969) and c:IsPublic()
end
function c69006.recop2(e,tp,eg,ep,ev,re,r,rp)
    local rev=Duel.GetMatchingGroup(c69011.revealed,tp,LOCATION_HAND,0,nil)
    local ct=rev:GetCount()
    Duel.Recover(tp,ct*300,REASON_EFFECT)
end
function c69006.rectg2(e,tp,eg,ep,ev,re,r,rp,chk) 
    if chk==0 then return Duel.IsExistingMatchingCard(c69006.revealed,tp,LOCATION_HAND,0,1,nil) end
    local rev=Duel.GetMatchingGroupCount(c69011.revealed,tp,LOCATION_HAND,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,rev*300)
end
