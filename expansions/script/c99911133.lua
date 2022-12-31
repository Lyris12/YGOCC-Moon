--Allured by the Dark
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
end
function cid.counterfilter(c)
	return c:GetSummonLocation(LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND) or c:IsRace(RACE_ZOMBIE)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
end
function cid.thfilter(c)
	return (c:IsSetCard(0x2ed) or c:IsCode(table.unpack(c99911130.ACEFTD))) and c:IsAbleToHand()
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsCode(71200730)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD+LOCATION_HAND,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND) and Duel.IsExistingMatchingCard(cid.cfilter,e:GetHandler():GetControler(),LOCATION_ONFIELD,0,1,nil) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsPlayerCanDraw(tp,1)
			and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD+LOCATION_HAND,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
			and Duel.IsExistingMatchingCard(cid.cfilter,e:GetHandler():GetControler(),LOCATION_ONFIELD,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.ShuffleDeck(tp)
			Duel.Draw(tp,1,REASON_EFFECT)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetTarget(cid.splimit)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function cid.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end