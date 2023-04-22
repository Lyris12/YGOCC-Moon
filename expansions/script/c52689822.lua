--Racing Hearts
--Cuori Gareggianti
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[If you have an Engaged monster: Both players take turns excavating the top card of their Deck. As soon as a player excavates a monster with a Level, they apply 1 of these effects, also both players shuffle the rest back into their Decks.
	● They add the excavated monster to their hand, and if they do, their opponent draws 1 card.
	● They send the excavated monster to the GY, and if they do, they increase the Energy of their Engaged monster by the Level the excavated monster had in the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_DRAW|CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetCondition(aux.IsExistingEngagedCond(0))
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY, except the turn it was sent there: You can banish this card; both players draw 1 card for each Drive Monster on the field (max. 5),
	then they reveal all the drawn cards, and if they do, the player that revealed the lower number of Drive Monsters (both players if it is a draw), sends all cards they drew to the GY -1.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_DRAW|CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.SSRestrictionCost(aux.MonsterFilter(TYPE_DRIVE),false,nil,id,nil,4,aux.bfgcost))
	e2:SetTarget(s.drawtg)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)
end
function s.thfilter(c,p)
	return c:IsMonster() and c:HasLevel() and c:IsAbleToHand(p)
end
function s.tgfilter(c,en)
	if not en or not (c:IsMonster() and c:HasLevel() and c:IsAbleToGrave()) then return false end
	local lv=c:GetLevel()
	return en:IsCanUpdateEnergy(lv,tp,REASON_EFFECT)
end
function s.tgfilter_oppo(c,tp)
	return Duel.IsPlayerCanSendtoGrave(1-tp,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1 = Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_DECK,1,nil,1-tp)
			and Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1)
		local b2 = Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,Duel.GetEngagedCard(tp)) and Duel.IsExistingMatchingCard(s.tgfilter_oppo,tp,0,LOCATION_DECK,1,nil,tp)
			and Duel.GetEngagedCard(1-tp)~=nil
		return b1 or b2
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local turnp=Duel.GetTurnPlayer()
	local decks = {Duel.GetDeck(tp), Duel.GetDeck(1-tp)}
	local ct = {#decks[tp+1]-1, #decks[2-tp]-1}
	local excav
	local ok=true
	while ok do
		for p = turnp, 1-turnp, 1-2*turnp do
			if ct[p+1]>=0 then
				excav=Duel.GetFirstMatchingCard(Card.IsSequence,p,LOCATION_DECK,0,nil,ct[p+1])
				Duel.ConfirmCards(1-tp,excav)
				if excav:IsMonster() and excav:HasLevel() then
					ok=false
					break
				end
			end
		end
		if not ok then
			break
		end
		ct[1], ct[2] = ct[1]-1, ct[2]-1
	end
	if excav then
		local p=excav:GetControler()
		local lv=excav:GetLevel()
		local en=Duel.GetEngagedCard(p)
		local b1=excav:IsAbleToHand(p)
		local b2 = (en~=nil and en:IsCanUpdateEnergy(lv,p,REASON_EFFECT) and ((p==tp and excav:IsAbleToGrave()) or (p==1-tp and Duel.IsPlayerCanSendtoGrave(p,excav))))
		local opt=aux.Option(p,id,1,b1,b2)
		if opt==0 then
			local _,hct=Duel.Search(excav,p,p)
			if hct>0 then
				Duel.Draw(1-p,1,REASON_EFFECT)
			end
			
		elseif opt==1 then
			if Duel.SendtoGrave(excav,REASON_EFFECT)>0 and excav:IsLocation(LOCATION_GRAVE) then
				en=Duel.GetEngagedCard(p)
				if en:IsCanUpdateEnergy(lv,p,REASON_EFFECT) then
					en:UpdateEnergy(lv,p,REASON_EFFECT,true,e:GetHandler())
				end
			end
		end
	end
	Duel.ShuffleDeck(tp)
	Duel.ShuffleDeck(1-tp)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:HasFlagEffectLabel(id,e:GetLabel()) then
		return true
	else
		e:Reset()
		return false
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct = math.min(3,Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsMonster,TYPE_DRIVE),tp,LOCATION_MZONE,LOCATION_MZONE,nil))
	if chk==0 then
		return ct>0 and Duel.IsPlayerCanDraw(tp,ct) and Duel.IsPlayerCanDraw(1-tp,ct) and Duel.IsPlayerCanSendtoGrave(tp) and Duel.IsPlayerCanSendtoGrave(1-tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,ct)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local ct = math.min(3,Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsMonster,TYPE_DRIVE),tp,LOCATION_MZONE,LOCATION_MZONE,nil))
	if ct<=0 then return end
	local d1=Duel.Draw(tp,ct,REASON_EFFECT)
	local g1=Duel.GetOperatedGroup(d1)
	local d2=Duel.Draw(1-tp,ct,REASON_EFFECT)
	local g2=Duel.GetOperatedGroup(d2)
	local g=g1+g2
	if d1+d2>0 then
		Duel.BreakEffect()
		if d1>0 then
			Duel.ConfirmCards(1-tp,g1)
		end
		if d2>0 then
			Duel.ConfirmCards(tp,g2)
		end
		local n={g1:FilterCount(Card.IsMonster,nil,TYPE_DRIVE),g2:FilterCount(Card.IsMonster,nil,TYPE_DRIVE)}
		for p=tp,1-tp,1-2*tp do
			if n[p+1]<=n[2-p] then
				local pg=g:Filter(Card.IsControler,nil,p)
				if #pg>1 then
					Duel.HintMessage(p,HINTMSG_TOGRAVE)
					local sg=pg:FilterSelect(p,Card.IsAbleToGrave,#pg-1,#pg-1,nil)
					if #sg>0 then
						Duel.HintSelection(sg)
						Duel.SendtoGrave(sg,REASON_EFFECT)
					end
				end
			end
		end
	end
end