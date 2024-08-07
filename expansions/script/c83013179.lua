--Seatector Landwalker
--Keddy was here~
local cod,id=GetID()
function cod.initial_effect(c)
	--Synchro Summon
    c:EnableReviveLimit()
    aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WATER),1)
	--Equip
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_GRAVE_ACTION)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(cod.eqcon)
    e1:SetTarget(cod.eqtg)
    e1:SetOperation(cod.eqop)
    c:RegisterEffect(e1)
    --Draw
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,83013279)
    e2:SetTarget(cod.target)
    e2:SetOperation(cod.operation)
    c:RegisterEffect(e2)
end

--Equip
function cod.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cod.cfilter(c,tp,tc)
	return c:IsType(TYPE_UNION) and aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function cod.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cod.cfilter(chkc,tp,e:GetHandler()) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(cod.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(cod.cfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,0,0)
end
function cod.cfilter2(c,tp,exc)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_UNION) and c:CheckUniqueOnField(tp) and not c:IsForbidden() and Duel.IsExistingMatchingCard(cod.mfilter,tp,LOCATION_MZONE,0,1,exc,c)
end
function cod.mfilter(c,ec)
	return c:IsFaceup() and aux.CheckUnionEquip(ec,c) and ec:CheckUnionTarget(c)
end
function cod.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc and not tc:IsRelateToEffect(e) or not cod.cfilter(tc,tp,c) then return end
	if not Duel.Equip(tp,tc,c,false) then return end
	aux.SetUnionState(tc)
	local eg=Duel.GetMatchingGroup(aux.NecroValleyFilter(cod.cfilter2),tp,LOCATION_GRAVE,0,c,tp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and eg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local eqc=eg:Select(tp,1,1,nil):GetFirst()
		if not eqc then return end
		local mg=Duel.GetMatchingGroup(cod.mfilter,tp,LOCATION_MZONE,0,e:GetHandler(),eqc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local mc=mg:Select(tp,1,1,e:GetHandler()):GetFirst()
		if not mc then return end
		if not Duel.Equip(tp,eqc,mc,false) then return end
		aux.SetUnionState(eqc)
	end
end

--Draw
function cod.filter(c)
    return c:IsType(TYPE_UNION) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToDeck()
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cod.filter(chkc) end
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
        and Duel.IsExistingTarget(cod.filter,tp,LOCATION_GRAVE,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,cod.filter,tp,LOCATION_GRAVE,0,3,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cod.operation(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
    Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
    local g=Duel.GetOperatedGroup()
    if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
    local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
    if ct==3 then
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
