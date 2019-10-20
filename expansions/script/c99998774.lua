--Forbidden Rune - Chaos Transference
function c99998774.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
	e1:SetCountLimit(1,99998774)
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(c99998774.target)
    e1:SetOperation(c99998774.activate)
    c:RegisterEffect(e1)
end
function c99998774.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE+LOCATION_REMOVED)>=0 and Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c99998774.activate(e,tp,eg,ep,ev,re,r,rp)
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    local g=Duel.GetFieldGroup(p,LOCATION_GRAVE+LOCATION_REMOVED,0)
    if g:GetCount()==0 then return end
    Duel.SendtoDeck(g,nil,1,REASON_EFFECT)
    Duel.ShuffleDeck(p)
    Duel.BreakEffect()
    Duel.Draw(p,1,REASON_EFFECT)
end