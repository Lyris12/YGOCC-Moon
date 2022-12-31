--Bestia Puntodifuoco
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),4,2)
	c:EnableReviveLimit()
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cid.sccon)
	e1:SetTarget(cid.sctg)
	e1:SetOperation(cid.scop)
	c:RegisterEffect(e1)
	--send to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(cid.tgcost)
	e2:SetTarget(cid.tgtg)
	e2:SetOperation(cid.tgop)
	c:RegisterEffect(e2)
end
--filters
function cid.scfilter(c)
	return c:IsSetCard(0xb05) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function cid.checkact(c)
	return c:IsFaceup() and c:IsDisabled() and c:IsAbleToGrave()
end
function cid.tgfilter(c,typ)
	return cid.checkact(c) and c:IsType(typ)
end
--search
function cid.sccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function cid.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--send to GY
function cid.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function cid.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.checkact,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(cid.checkact,tp,0,LOCATION_ONFIELD,nil)
	local num=1
	local typ,opval={},{}
	if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then
		typ[num]=aux.Stringid(id,2)
		opval[num-1]=TYPE_MONSTER
		num=num+1
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_SPELL) then
		typ[num]=aux.Stringid(id,3)
		opval[num-1]=TYPE_SPELL
		num=num+1
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_TRAP) then
		typ[num]=aux.Stringid(id,4)
		opval[num-1]=TYPE_TRAP
		num=num+1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local op=Duel.SelectOption(tp,table.unpack(typ))
	e:SetLabel(opval[op])
	local tg=g:Filter(Card.IsType,nil,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,tg:GetCount(),0,0)
end
function cid.tgop(e,tp,eg,ep,ev,re,r,rp)
	local arc=e:GetLabel()
	local g=Duel.GetMatchingGroup(cid.tgfilter,tp,0,LOCATION_ONFIELD,nil,arc)
	if g:GetCount()==0 then return end
	Duel.SendtoGrave(g,nil,REASON_EFFECT)
end