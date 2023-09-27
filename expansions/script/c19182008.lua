--Aircaster Twins
--created by Alastar Rainford, coded by Lyris
--New auxiliaries by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:Desc(3)
	e0:SetCategory(CATEGORY_TODECK)
	e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetFunctions(s.atkcon,nil,s.atktg,s.atkop)
	e0:SetReset(RESET_PHASE|PHASE_END)
	local ex=aux.AddAircasterExcavateEffect(c,6,EFFECT_TYPE_QUICK_O,0,id,e0,CATEGORY_TODECK,true)
	e0:SetLabelObject(ex)
	aux.AddAircasterEquipEffect(c,1)
	--You can send 1 Spell/Trap you control to the GY; add 1 "Aircaster" card from your Deck or GY to your hand.
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_ONFIELD)
	e1:HOPT(true)
	e1:SetFunctions(s.econ,s.thcost,s.thtg,s.thop)
	c:RegisterEffect(e1)
end
function s.cfilter(c,eid,e)
	local re=c:GetReasonEffect()
	return c:IsMonster() and c:IsRace(RACE_PSYCHIC) and c:IsReason(REASON_EFFECT) and re and re==e and re:GetFieldID()==eid
end
function s.atkfilter(c)
	return c:IsSpellTrapOnField() and c:IsAbleToDeck()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local eid=e:GetLabel()
	if not eid then return false end
	return eg:IsExists(s.cfilter,1,nil,eid,e:GetLabelObject())
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.atkfilter(chkc) end
	if chk==0 then return true end
	local eid=e:GetLabel()
	local ct=eg:FilterCount(s.cfilter,nil,eid,e:GetLabelObject())
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,g:GetControlers(),LOCATION_ONFIELD)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

function s.costfilter(c,tp,h)
	return c:IsSpellTrapOnField() and c:IsAbleToGraveAsCost() and (c:IsSetCard(ARCHE_AIRCASTER) or Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,c))
end
function s.thfilter(c)
	return c:IsSetCard(ARCHE_AIRCASTER) and c:IsAbleToHand()
end
function s.econ(e)
	return e:GetHandler():IsSpell(TYPE_EQUIP)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.costfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end