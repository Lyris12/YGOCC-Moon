--Knight of Decay, Gearstalt
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,5,s.sumcon,{s.tlfilter,true})
	c:EnableReviveLimit()
	--If this card is Time Leap Summoned while there are 3 or less monsters in your GY: You can send the top 3 cards of your Deck to the GY.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.ddescon)
	e1:SetTarget(s.ddestg)
	e1:SetOperation(s.ddesop)
	c:RegisterEffect(e1)
	--Once per turn, at the start of the Battle Phase: You can target 1 banished Zombie or Machine monster; return it to the GY, and if you do, you can apply 1 of the following effects based on it's type.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
function s.sumcon(e,c)
	local tp=c:GetControler()
	return Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>=1
end
function s.tlfilter(c,e,mg)
	local tp=c:GetControler()
	local ef=e:GetHandler():GetFuture()
	return (c:IsRace(RACE_MACHINE) and (c:IsLevel(ef-1) or c:IsLevel(ef))) or (c:IsRace(RACE_ZOMBIE) and (c:IsLevel(ef-1) or c:IsLevel(ef-2)))
end
function s.ddescon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP) and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)<=3
end
function s.ddestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.ddesop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.DiscardDeck(p,d,REASON_EFFECT)
end
function s.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) or c:IsRace(RACE_MACHINE)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		if Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)>0 then
			--● Machine: Draw 1 card.
			if sg:GetFirst():IsRace(RACE_MACHINE) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.Draw(tp,1,REASON_EFFECT)
			--● Zombie: Choose 1 monster your opponent controls, and until the end of the next turn, you gain control of it, also, it becomes a Zombie monster.
			elseif sg:GetFirst():IsRace(RACE_ZOMBIE) and Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
				local g=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
				if #g>0 then
					Duel.HintSelection(g)
					tc=g:GetFirst()
					if Duel.GetControl(tc,tp,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2) then
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_CHANGE_RACE)
						e1:SetValue(RACE_ZOMBIE)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
						tc:RegisterEffect(e1)
					end
				end
			end
		end
	end
end