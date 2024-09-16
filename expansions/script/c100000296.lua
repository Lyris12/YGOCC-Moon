--[[
Dynastygian Launch
Lancio Dinastigiano
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Special Summon 1 "Dynastygian" monster from your hand or GY, then, if your opponent activated a "Dynastygian" Normal Trap this turn, you can apply the following effect.
	● Immediately after this effect resolves, take 1 "Dynastygian" monster from your Deck with a different original name from all face-up "Dynastygian" monsters you control,
	and either add it to your hand or Special Summon it (but negate its effects, also banish it when it leaves the field).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
	--[[If this card is in your GY while you control a "Dynastygian" monster: You can target 1 of your banished "Dynastygian" Traps; shuffle both it and this card into the Deck, then draw 1 card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(aux.FaceupFilter(Card.IsSetCard,ARCHE_DYNASTYGIAN),LOCATION_MZONE,0,1),
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
end
function s.chainfilter(re,rp,cid)
	return not (re:GetActiveType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSetCard(ARCHE_DYNASTYGIAN))
end

--E1
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.filter(c,e,tp,mg,ftchk)
	return c:IsMonster() and c:IsSetCard(ARCHE_DYNASTYGIAN) and not mg:IsExists(s.codefilter,1,nil,{c:GetOriginalCodeRule()})
		and (c:IsAbleToHand() or (ftchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.codefilter(c,codes)
	return c:IsOriginalCodeRule(table.unpack(codes))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0 then
		local ftchk=Duel.GetMZoneCount(tp)>0
		local mg=Duel.Group(aux.FaceupFilter(Card.IsSetCard,ARCHE_DYNASTYGIAN),tp,LOCATION_MZONE,0,nil)
		if Duel.IsExists(false,s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,mg,ftchk) and Duel.SelectYesNo(tp,STRING_ASK_APPLY_ADDITIONAL) then
			aux.ApplyEffectImmediatelyAfterResolution(s.afterResolution,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp,true)
		end
	end
end
function s.afterResolution(e,tp,eg,ep,ev,re,r,rp,_e,IsEndOfChain)
	local ftchk=Duel.GetMZoneCount(tp)>0
	local mg=Duel.Group(aux.FaceupFilter(Card.IsSetCard,ARCHE_DYNASTYGIAN),tp,LOCATION_MZONE,0,nil)
	local c=Duel.Select(HINTMSG_OPERATECARD,false,tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mg,ftchk):GetFirst()
	if c then
		local b1=c:IsAbleToHand()
		local b2=ftchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		if not b1 and not b2 then return end
		local opt=aux.Option(tp,nil,nil,{b1,STRING_ADD_TO_HAND},{b2,STRING_SPECIAL_SUMMON})
		if opt==0 then
			Duel.Search(c)
		elseif opt==1 then
			if not IsEndOfChain then
				Duel.SpecialSummonMod(e,c,0,tp,tp,false,false,POS_FACEUP,nil,SPSUM_MOD_NEGATE,SPSUM_MOD_REDIRECT)
			else
				local h=e:GetHandler()
				local e1=Effect.CreateEffect(h)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_SPSUMMON_PROC)
				e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
				e1:SetRange(LOCATION_DECK)
				e1:SetOperation(s.sprop)
				e1:SetValue(SUMMON_VALUE_PRIVATE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				c:RegisterEffect(e1,true)
				aux.RegisterResetAfterSpecialSummonRule(h,tp,e1,_e)
				Duel.SpecialSummonRule(tp,c,SUMMON_VALUE_PRIVATE)
			end
		end
	end
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
	c:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
	c:RegisterEffect(e2,true)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(STRING_BANISH_REDIRECT)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetReset(RESET_EVENT|RESETS_REDIRECT)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3,true)
end

--E2
function s.thfilter(c)
	return c:IsFaceup() and c:IsTrap() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsAbleToDeck()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsBanished() and chkc:IsControler(tp) and s.thfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToDeck() and Duel.IsExists(true,s.thfilter,tp,LOCATION_REMOVED,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g+c,2,0,0)
	aux.DrawInfo(tp,1)
end
function s.tgchk(c)
	return c:IsRelateToChain() and c:IsAbleToDeck()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(c,tc):Filter(s.tgchk,nil)
	if #g==2 and Duel.ShuffleIntoDeck(g)==2 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end