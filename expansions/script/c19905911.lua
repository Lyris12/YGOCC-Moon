--MMS - Magica Multi Scintilla
--Script by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--search
	c:Activate(nil,CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION,nil,nil,nil,
		nil,
		nil,
		nil,
		s.activate
	)
	--mill and boost
	c:Ignition(2,CATEGORY_TOGRAVE+CATEGORY_DECKDES+CATEGORY_ATKCHANGE,EFFECT_FLAG_CARD_TARGET,LOCATION_SZONE,1,
		nil,
		nil,
		aux.Target(aux.FaceupFilter(Card.IsSetCard,0xd71),LOCATION_MZONE,0,1,1,nil,
			s.check,
			{CATEGORY_ATKCHANGE,0},
			nil,
			nil,
			aux.MillInfo(0,3)
		),
		s.atkop
	)
end

function s.thfilter(c,p)
	return c:NotBanishedOrFaceup() and c:IsMonster() and c:IsSetCard(0xd71) and c:IsAbleToHand(p)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToChain() then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GB,LOCATION_REMOVED,nil,tp)
	if #g>0 and not Duel.PlayerHasFlagEffect(tp,id) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.Search(sg,tp)
		end
	end
end

function s.check(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerCanDiscardDeck(tp,3)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToChain() or Duel.DiscardDeck(tp,3,REASON_EFFECT)==0 then return end
	local g=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	local ct=g:FilterCount(Card.IsSetCard,nil,0xd71)
	if ct==0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToChain() then
		tc:UpdateATK(ct*300,RESET_PHASE+PHASE_END,e:GetHandler())
	end
end