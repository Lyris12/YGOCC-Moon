--Peach Beach Guardian Spirit, Tamame-No-Mae
function c69009.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x6969),5,2,nil,nil,6)
	c:EnableReviveLimit()
    --Xyz Summon LP Gain x Material
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(69009,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(c69009.reccon)
    e1:SetTarget(c69009.rectg)
    e1:SetOperation(c69009.recop)
    c:RegisterEffect(e1)
	--End Phase Detach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69009,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c69009.rmcon)
	e2:SetOperation(c69009.rmop)
	c:RegisterEffect(e2)
	--Effect Resistence
	local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetValue(aux.tgoval)
    e3:SetLabel(1)
    e3:SetCondition(c69009.effcon)
    c:RegisterEffect(e3)
	--Gain ATK
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(c69009.atkcon)
	e4:SetValue(c69009.val)
	e4:SetLabel(3)
	c:RegisterEffect(e4)
	--cannot be target
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetCondition(c69009.effcon)
	e5:SetLabel(2)
	c:RegisterEffect(e5)
	--disable spsummon
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(0,1)
	e6:SetCondition(c69009.effcon)
	e6:SetLabel(4)
	c:RegisterEffect(e6)
	--Nuke
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(69009,1))
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c69009.gycon)
	e7:SetTarget(c69009.gytg)
	e7:SetOperation(c69009.gyop)
	e7:SetCost (c69009.gycost)
	e7:SetLabel(6)
	c:RegisterEffect(e7)
end
function c69009.reccon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function c69009.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local ct=e:GetHandler():GetOverlayCount()*500
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(ct)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct)
end
function c69009.recop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Recover(p,d,REASON_EFFECT)
end
function c69009.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c69009.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetOverlayCount()>0 then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end
function c69009.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>=e:GetLabel()
end
function c69009.atkcon(e,tp,eg,ep,ev,re,r,rp)
     local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp)>Duel.GetLP(1-tp) and
	e:GetHandler():GetOverlayCount()>=e:GetLabel()
end
function c69009.val(e,c)
local tp=e:GetHandlerPlayer()
	return math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))/2
end
function c69009.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD+LOCATION_EXTRA,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
function c69009.gyop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD+LOCATION_EXTRA,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
function c69009.gfilter(c)
    return c:IsFaceup() and c:IsCode(69010) 
end
function c69009.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c69009.gfilter,tp,LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,c69009.gfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.Destroy(g,REASON_COST)
end
--filter for EFFECT_CANNOT_BE_EFFECT_TARGET + opponent
function Auxiliary.tgoval(e,re,rp)
    return rp==1-e:GetHandlerPlayer()
end
function c69009.gycon(e,tp,eg,ep,ev,re,r,rp)
     local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp)>Duel.GetLP(1-tp) and
	e:GetHandler():GetOverlayCount()>=e:GetLabel()
end