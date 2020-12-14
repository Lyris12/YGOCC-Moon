--created by Alastar Rainford, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	aux.AddRitualProcEqual2(c,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHO))
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(0xff)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetLabelObject(e2)
	e3:SetCondition(function(e) local g=e:GetLabelObject():GetLabelObject() e:SetLabel(#g) local res=#g>0 g:DeleteGroup() return res end)
	e3:SetTarget(s.atarget)
	e3:SetOperation(s.aoperation)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)) and c:IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if not c:IsRelateToEffect(e) or Duel.Remove(c,POS_FACEUP,REASON_EFFECT)==0 or not c:IsLocation(LOCATION_REMOVED)
		or not Duel.IsPlayerCanDiscardDeck(tp,ct) or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	local t={1}
	if Duel.IsPlayerCanDiscardDeck(tp,ct*2) then table.insert(t,2) end
	local n=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.ConfirmDecktop(tp,ct*n)
	local g=Duel.GetDecktopGroup(tp,ct*n)
	local tg=g:Filter(Card.IsRace,nil,RACE_PSYCHO)
	if Duel.SendtoGrave(tg,REASON_EFFECT+REASON_REVEAL)==0 then Duel.ShuffleDeck(tp) end
	tg:KeepAlive()
	e:SetLabelObject(tg)
	Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,re,r,rp,tp,0)
end
function s.atarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,ct,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_GRAVE)
end
function s.aoperation(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,ct,ct,nil)
	if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
end
