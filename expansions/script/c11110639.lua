--Magnus, Royal Swordsmaster
--Magnus, Maestrospadaccino Reale
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,10)
	--[[Each time a Warrior monster(s) is Special Summoned, immediately increase this card's Energy by 1.]]
	c:DriveEffect(0,0,nil,EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS,EFFECT_FLAG_DELAY,EVENT_SPSUMMON_SUCCESS,
		s.encon_nonactivated,
		nil,
		nil,
		s.enop_nonactivated
	)
	c:DriveEffect(0,1,nil,EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS,nil,EVENT_SPSUMMON_SUCCESS,
		s.encon_inchain,
		nil,
		nil,
		s.enop_inchain
	)
	c:DriveEffect(0,0,nil,EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS,nil,EVENT_CHAIN_SOLVED,
		s.encon_resolved,
		nil,
		nil,
		s.enop_resolved
	)
	--[[[-4]: Reveal 1 "Reinforcement of the Army" in your hand or Deck; add 1 Warrior monster from your Deck to your hand, except "Magnus, Royal Swordsmaster",
	and if you do, banish the revealed card.]]
	c:DriveEffect(-4,3,CATEGORIES_SEARCH|CATEGORY_REMOVE,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		aux.DummyCost,
		s.thtg,
		s.thop
	)
	--[[[-4]: Target up to 5 Warrior monsters in your GY; shuffle them into the Deck, then, if you shuffled 5 cards into your Main Deck with this effect,
	you can add 1 of your banished Spells to your hand.]]
	c:DriveEffect(-4,4,CATEGORY_TODECK|CATEGORY_TOHAND,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.tdtg,
		s.tdop
	)
	--[[You cannot Special Summon monsters, except Warrior monsters]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	c:RegisterEffect(e0)
	--[[If this card is Drive Summoned: You can target 1 card on the field; destroy it and all other cards in its same column,
	also neither player can use the unused Zones in that column, until the end of the next turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(6)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.DriveSummonedCond)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--[[If this card is sent to the GY: You can send Warrior monsters from your hand to the GY whose total Levels equal or exceed 7, and if you do, add this card to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(7)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetTarget(s.rctg)
	e2:SetOperation(s.rcop)
	c:RegisterEffect(e2)
end
--FD1
function s.egfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
--D1
function s.encon_nonactivated(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.egfilter,1,nil) and (not re or not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS))
end
function s.enop_nonactivated(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsEngaged() and c:IsCanUpdateEnergy(1,tp,REASON_EFFECT,e) then
		c:UpdateEnergy(1,tp,REASON_EFFECT,true,c)
	end
end
function s.encon_inchain(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.egfilter,1,nil) and re and re:IsHasType(EFFECT_TYPE_ACTIONS) and not re:IsHasType(EFFECT_TYPE_CONTINUOUS)
end
function s.enop_inchain(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
function s.encon_resolved(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.enop_resolved(e,tp,eg,ep,ev,re,r,rp)
	local n=Duel.GetFlagEffect(tp,id)
	Duel.ResetFlagEffect(tp,id)
	local c=e:GetHandler()
	for i=1,n do
		if c:IsEngaged() and c:IsCanUpdateEnergy(1,tp,REASON_EFFECT,e) then
			c:UpdateEnergy(1,tp,REASON_EFFECT,true,c)
		end
	end
end

--FD2
function s.rvfilter(c,tp)
	return (not c:IsLocation(LOCATION_HAND) or not c:IsPublic()) and c:IsCode(CARD_ROTA) and c:IsAbleToRemove() and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,c)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(5) and not c:IsCode(id) and c:IsAbleToHand()
end
--D2
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExists(false,s.rvfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_CONFIRM,false,tp,s.rvfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.SetTargetCard(g:GetFirst())
		Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,aux.ExceptThis(tc))
	if #g>0 then
		local ct,ht=Duel.Search(g,tp)
		if ct>0 and ht>0 and tc:IsRelateToChain() then
			Duel.Banish(tc)
		end
	end
end

--FE3
function s.tdfilter(c)
	return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeck()
end
function s.thfilter2(c)
	return c:IsFaceup() and c:IsSpell() and c:IsAbleToHand()
end
--E3
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsInGY() and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,5,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 and Duel.ShuffleIntoDeck(g,tp,LOCATION_DECK) then
		local tg=Duel.Group(s.thfilter2,tp,LOCATION_REMOVED,0,1,nil)
		if #tg>0 and e:GetHandler():AskPlayer(tp,5) then
			Duel.HintMessage(tp,HINTMSG_ATOHAND)
			local sg=tg:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.Search(sg,tp)
			end
		end
	end
end

--E0
function s.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end

--E1
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		return Duel.IsExists(true,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	local g=Duel.Select(HINTMSG_DESTROY,true,tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local cg=g:GetFirst():GetColumnGroup()
	g:Merge(cg)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		local p=tc:GetControler()
		local seq=tc:GetSequence()
		local seqloc=tc:GetLocation()
		local zones=tc:GetZone(tp)|tc:GetColumnZone(LOCATION_ONFIELD,tp)
		local cg=tc:GetColumnGroup()
		cg:AddCard(tc)
		if #cg>0 then
			Duel.Destroy(cg,REASON_EFFECT)
		end
		local g=Duel.GetColumnGroupFromSequence(p,seq,seqloc)
		for sc in aux.Next(g) do
			local ctrl=sc:IsControler(tp)
			local seq=sc:GetSequence()
			zones=zones&~(ctrl and (1<<seq) or (1<<(16+seq)))
			if sc:IsInEMZ() then
				zones=zones&~(ctrl and (1<<(27-seq)) or (1<<(11-seq)))
			end
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetValue(zones)
		e1:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	end
end

--FILTERS E2
function s.tgfilter(c)
	return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:HasLevel() and c:IsAbleToGrave()
end
--E2
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=Duel.Group(s.tgfilter,tp,LOCATION_HAND,0,nil)
		return c:IsAbleToHand() and #g>0 and g:CheckWithSumGreater(Card.GetLevel,7)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_HAND)
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.tgfilter,tp,LOCATION_HAND,0,nil)
	if #g<=0 then return end
	local tg=g:SelectWithSumGreater(tp,Card.GetLevel,7)
	if #tg>0 and Duel.SendtoGrave(tg,REASON_EFFECT)>0 and aux.PLChk(tg,nil,LOCATION_GRAVE) then
		local c=e:GetHandler()
		if c:IsRelateToChain() and not c:IsHasEffect(EFFECT_NECRO_VALLEY) then
			Duel.Search(c,tp)
		end
	end
end