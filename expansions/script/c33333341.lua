--Scolaro del Maestro dei Sigilli, Hisaki
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--ss
	c:Ignition(0,CATEGORY_SPECIAL_SUMMON,nil,LOCATION_HAND+LOCATION_GRAVE,true,
		s.spcon,
		aux.ToGraveCost(aux.Filter(Card.IsSetCard,0x7ea),LOCATION_HAND+LOCATION_DECK,0,1,1,true),
		aux.SSTarget(SUBJECT_THIS_CARD),
		aux.SSOperationMod(SPSUM_MOD_REDIRECT,SUBJECT_THIS_CARD,nil,nil,nil,nil,nil,{LOCATION_HAND,aux.Stringid(id,1)})
	)
	--add to hand
	c:Ignition(2,CATEGORIES_SEARCH+CATEGORY_HANDES,nil,LOCATION_MZONE,true,
		nil,
		aux.TributeSelfCost,
		s.thtg,
		s.thop
	)
end
function s.filter(c)
	return c:IsFacedown() or not c:IsSetCard(0x7ec)
end
function s.spcon(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.thfilter(c)
	return c:IsSetCard(0x7ec) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		local en=Duel.GetEngagedCard(tp)
		if en and en:IsMonster() and en:IsSetCard(0x7eb) then
			local b1=en:IsCanUpdateEnergy(2,tp,REASON_EFFECT)
			local b2=en:IsCanUpdateEnergy(-2,tp,REASON_EFFECT)
			if not b1 and not b2 then return end
			local opt=aux.Option(id,tp,3,b1,b2)
			if not opt then return end
			local ct = (opt==0) and 2 or -2
			Duel.BreakEffect()
			en:UpdateEnergy(ct,tp,REASON_EFFECT,true,e:GetHandler())
			
		elseif Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) then
			Duel.BreakEffect()
			Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil,REASON_EFFECT)
		end
	end
end