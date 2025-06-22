--[[
Unknown HERO Cloak
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	--During the Battle Step or Damage Step, if a monster you control battles an opponent's monster, even during damage calculation (Quick Effect): You can discard this card; the ATK of those monsters becomes 0, then send the top card of your Deck to the GY, and if you sent a monster to the GY this way, your monster gains ATK equal to the ATK or DEF (whichever is higher, or its ATK if tied) of that sent monster. These changes last until the end of that battle.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE|TIMING_DAMAGE_STEP|TIMING_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetFunctions(s.atkcon,aux.DiscardSelfCost,s.atktg,s.atkop)
	c:RegisterEffect(e1)                                                      
	--If you Ritual Summon an "Unknown HERO" Ritual Monster(s) while this card is in your GY (except during the Damage Step): You can add this card to your hand, and if you do, draw 1 card.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetLabelObject(aux.AddThisCardInGraveAlreadyCheck(c))
	e2:HOPT()
	e2:SetFunctions(aux.AlreadyInRangeEventCondition(s.cfilter),nil,s.thtg,s.thop)
	c:RegisterEffect(e2)
end	
--E1
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local b1,b2=Duel.GetBattleMonsters(tp)
	return b1 and b2 and b1:IsRelateToBattle() and b2:IsRelateToBattle() 
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDiscardDeck(tp,1)
	end
	local g=Group.FromCards(Duel.GetBattleMonsters(tp))
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chk=false
	local g=Duel.GetTargetCards():Filter(aux.FaceupFilter(Card.IsRelateToBattle),nil)
	for tc in aux.Next(g) do
		local ce=tc:ChangeATK(0,RESET_PHASE|PHASE_DAMAGE,{c,true})
		if not tc:IsImmuneToEffect(ce) then
			chk=true
		end
	end
	if chk then
		Duel.BreakEffect()
		if Duel.DiscardDeck(tp,1,REASON_EFFECT)>0 then
			local tc=Duel.GetGroupOperatedByThisEffect(e):GetFirst()
			if tc and tc:IsLocation(LOCATION_GRAVE) and tc:IsMonster() then
				g=g:Filter(aux.FaceupFilter(Card.IsRelateToBattle),nil)
				local b1=g:Filter(Card.IsControler,nil,tp):GetFirst()
				if b1 then
					b1:UpdateATK(math.max(0,tc:GetAttack()),RESET_PHASE|PHASE_DAMAGE,{c,true})
				end
			end
		end
	end
end

--E2
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsMonster(TYPE_RITUAL) and c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO) and c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsSummonPlayer(tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHand() and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.DisableShuffleCheck()
		if Duel.SearchAndCheck(c) then
			Duel.ShuffleHand(c:GetControler())
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end