--Umbral Elemerge, Alisse
Duel.LoadScript("Elemerge.lua")
local ref,id=GetID()
function ref.initial_effect(c)
	aux.AddFusionProcFun2(c,ref.rcmatfilter,ref.attmatfilter,true)
	--OnSummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(ref.grtg)
	e1:SetOperation(ref.grop)
	c:RegisterEffect(e1)
	
end
function ref.rcmatfilter(c) return c:IsRace(RACE_SPELLCASTER) end
function ref.attmatfilter(c) return c:IsFusionAttribute(ATTRIBUTE_DARK) end

function ref.grtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsAbleToGrave() and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	local val=Elemerge.GetAttributeCount(ATTRIBUTE_DARK,3)
	if val>=1 then Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,val,tp,LOCATION_DECK)
		if val>=3 then Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND) end
	end
end
function ref.grop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		Elemerge.SummonLock(e)
		local val=Elemerge.GetAttributeCount(ATTRIBUTE_DARK,3)
		if val>=1 and Duel.Draw(tp,val,REASON_EFFECT)>=3 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,2,nil)
			if #g>0 then Duel.SendtoDeck(g,nil,0,REASON_EFFECT) end
		end
	end
end
