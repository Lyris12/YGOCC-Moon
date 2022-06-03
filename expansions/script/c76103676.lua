--Finale Scintillante
--Scripted by: XGlitchy30

local s,id=GetID()

s.effect_text = [[
●You can only use each effect of "Sparkling Finisher" once per turn.

① Apply 1 of the following effects depending on your opponent's LP.
● Equal to or higher than 8000: Inflict 2 damage to your opponent, also they send a monster with 2 or less ATK from their hand or Extra Deck to the GY (if any).
● Lower than 8000 but higher than or equal to 4100: Inflict 200 damage to your opponent, plus 200 damage for each "Sparks" in your GY.
● Lower than 4000 but higher than or equal to 2100: Inflict 2000 damage to your opponent, also you can draw 1 card, and if you do, take 2000 damage.
● Equal to or lower than 2000: Banish 3 "Sparks" from your GY, and if you do, your opponent's LP become 20000, and if they do, inflict 20000 damage to your opponent at the end of the turn.

② You can banish this card from your GY; add 1 "Sparkling Finisher" from your Deck to your hand, then you can add any number of "Sparks" from your Deck and/or GY to your hand.
]]

function s.initial_effect(c)
	c:Activate(0,CATEGORY_DAMAGE+CATEGORY_TOGRAVE+CATEGORY_DRAW+CATEGORY_REMOVE,false,false,{1,0},nil,nil,s.tg,s.op)
	c:Ignition(3,CATEGORY_SEARCH+CATEGORY_TOHAND,false,LOCATION_GRAVE,{1,1},nil,aux.bfgcost,aux.SearchTarget(s.thf,1),s.thop)
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lp=Duel.GetLP(1-tp)
	if chk==0 then
		return lp>2000 or Duel.IsExists(false,s.rmf,tp,LOCATION_GRAVE,0,3,nil)
	end
end

function s.rmf(c)
	return c:IsCode(76103675) and c:IsAbleToRemove()
end
function s.tgf(c)
	return c:IsMonster() and c:IsAttackBelow(2) and c:IsAbleToGrave()
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lp=Duel.GetLP(1-tp)
	if lp>=8000 then
		Duel.Damage(1-tp,2,REASON_EFFECT)
		local g=Duel.Group(s.tgf,tp,0,LOCATION_HAND+LOCATION_EXTRA,nil)
		if #g>0 then
			local tg=g:Select(1-tp,1,1,nil)
			if #tg>0 then
				Duel.SendtoGrave(tg,nil,REASON_EFFECT)
			end
		end
	elseif lp>=4100 then
		Duel.Damage(1-tp,200,REASON_EFFECT,true)
		local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,76103675)
		if ct>0 then
			Duel.Damage(1-tp,ct*200,REASON_EFFECT,true)
		end
		Duel.RDComplete()
	elseif lp>=2100 then
		Duel.Damage(1-tp,2000,REASON_EFFECT)
		if Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) and Duel.Draw(tp,1)>0 then
			Duel.Damage(tp,2000,REASON_EFFECT)
		end
	else
		local g=Duel.Group(aux.NecroValleyFilter(s.rmf),tp,LOCATION_GRAVE,0,nil)
		if #g<3 then return end
		local rg=g:Select(tp,3,3,nil)
		if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==3 and rg:IsExists(Card.IsLocation,3,nil,LOCATION_REMOVED) and Duel.GetLP(1-tp)~=20000 then
			Duel.SetLP(1-tp,20000)
			if Duel.GetLP(1-tp)==20000 then
				local e1=Effect.CreateEffect(c)
				e1:Desc(2)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetCountLimit(1)
				e1:SetOperation(s.damop)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function s.damop(e,tp)
	Duel.Damage(1-tp,20000,REASON_EFFECT)
	e:Reset()
end

function s.thf(c)
	return c:IsCode(id)
end
function s.thf2(c)
	return c:IsCode(76103675) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g,ct=aux.SearchOperation(s.thf,1)(e,tp,eg,ep,ev,re,r,rp)
	if ct>0 and #g>0 and Duel.IsExists(false,s.thf2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		local sg=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.NecroValleyFilter(s.thf2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,999,nil)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.Search(sg,tp)
		end
	end
end