--Basillcom
--coded by Concordia, cred Moon_Burst and André
function c68709323.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk&def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(300)
	e2:SetTarget(c68709323.AtkFilter)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--cannot be target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(c68709323.CanFilter)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	--draw
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(68709323,1))
    e5:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1,68709323)
    e5:SetCondition(c68709323.tkcon)
    e5:SetTarget(c68709323.tktg)
    e5:SetOperation(c68709323.tkop)
    c:RegisterEffect(e5)
    --todeck
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(68709323,0))
    e6:SetCategory(CATEGORY_TODECK)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCountLimit(1,68719323)
    e6:SetTarget(c68709323.tdtg)
    e6:SetOperation(c68709323.tdop)
    c:RegisterEffect(e6)
end
function c68709323.AtkFilter(e,c)
 	return c:IsSetCard(0xf08) or c:IsSetCard(0xf09)
 end
 function c68709323.CanFilter(e,c)
 	return c:IsSetCard(0xf09)
 end
 function c68709323.cfilter(c,tp)
    return c:GetSummonLocation()==LOCATION_EXTRA and c:IsSetCard(0xf09)
end
function c68709323.tkcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c68709323.cfilter,1,nil,tp)
end
function c68709323.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,0,1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,0,1)
end
function c68709323.tkop(e,tp,eg,ep,ev,re,r,rp)
    local h1=Duel.Draw(tp,1,REASON_EFFECT)
    if h1>0 or h2>0 then Duel.BreakEffect() end
    if h1>0 then
        Duel.ShuffleHand(tp)
        Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
    end
end
function c68709323.tdfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function c68709323.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c68709323.tdfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c68709323.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,c68709323.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function c68709323.tdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
    end
end