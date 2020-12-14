--created by Alastar Rainford, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCountLimit(1,id)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e0:SetCost(s.cost)
	e0:SetTarget(s.ptg)
	e0:SetOperation(s.pop)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_HAND)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetLabelObject(e2)
	e3:SetCondition(function(e) return e:GetLabelObject():GetLabel()>0 end)
	e3:SetTarget(s.atarget)
	e3:SetOperation(s.aoperation)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(s.con)
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_EQUIP_LIMIT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetValue(aux.TRUE)
	c:RegisterEffect(e6)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BATTLE_CONFIRM)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(function(e) local ec=e:GetHandler():GetEquipTarget() return ec~=nil and ec:GetBattleTarget()~=nil end)
	e5:SetOperation(s.op)
	c:RegisterEffect(e5)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa88) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return g:CheckSubGroup(function(sg) return sg:IsExists(Card.IsType,1,nil,TYPE_PENDULUM) end,3,3) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(g:SelectSubGroup(tp,function(sg) return sg:IsExists(Card.IsType,1,nil,TYPE_PENDULUM) end,false,3,3),nil,2,REASON_COST)
end
function s.spfilter(c,e,tp)
	local lv=c:GetLevel()
	if lv<=0 then lv=c:GetRank()>0 and c:GetRank() or c:GetLink() end
	return c:IsSetCard(0xa88) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and lv>0 and Duel.IsPlayerCanDiscardDeck(tp,lv)
end
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local lv=tc:GetLevel()
		if lv<=0 then lv=tc:GetRank()>0 and tc:GetRank() or tc:GetLink() end
		Duel.ConfirmDecktop(tp,lv)
		local dg=Duel.GetDecktopGroup(tp,lv)
		local tg=g:Filter(Card.IsRace,nil,RACE_PSYCHO)
		if Duel.SendtoGrave(tg,REASON_EFFECT+REASON_REVEAL)==0 then Duel.ShuffleDeck(tp) end
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) and not e:GetHandler():IsPublic() end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not Duel.IsPlayerCanDiscardDeck(tp,3)
		or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	local tg=g:Filter(Card.IsRace,nil,RACE_PSYCHO)
	if Duel.SendtoGrave(tg,REASON_EFFECT+REASON_REVEAL)==0 then Duel.ShuffleDeck(tp) end
	e:SetLabel(#tg)
	Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,re,r,rp,tp,0)
end
function s.atarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.aoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	Duel.Equip(tp,c,tc,true)
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa88) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil)
	if #g==0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not Duel.SelectYesNo(tp,1068) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	Duel.Equip(tp,tc,ec,true)
end
