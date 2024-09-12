--Anbionic Gilded Hourguard
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,2,s.sumcon,{s.tlfilter,true})
	--If this card is Time Leap Summoned: You can activate this effect, depending on the original Vibe of the monster used to Time Leap Summon this card.
	--● Positive or Negative: This card gains ATK equal to the total ATK of all other monsters and you currently control, until the end of this turn, also other monsters you control cannot attack for the rest of this turn.
	--● Neutral: Target the monster used to Time Leap Summon this card; shuffle it and 1 card your opponent controls into the Deck.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.tlcon)
	e1:SetTarget(s.tltg)
	e1:SetOperation(s.tlop)
	c:RegisterEffect(e1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	e0:SetLabelObject(e1)
	c:RegisterEffect(e0)
end
function s.checkmaxatk(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	return tg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.sumcon(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	return s.checkmaxatk(e) or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=20
end
function s.tlfilter(c,e)
	local tp=c:GetControler()
	local ef=e:GetHandler():GetFuture()
	return (c:IsLevelBelow(ef-1) and c:IsType(TYPE_TOKEN) and s.checkmaxatk(e)) or (Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=20 and c:IsSetCard(0xe57))
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	if not tc then
		e:GetLabelObject():SetLabel(999)
		return
	end
	e:GetLabelObject():SetLabel(s.GetOriginalVibe(tc)+1)
end
function s.tlcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function s.tdfilter(c,mg)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and mg:IsContains(c)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,c)
end
function s.tltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local vibe=e:GetLabel()-1
	local mg=c:GetMaterial()
	local op1=(vibe==0 and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil,mg))
	local op2=((vibe==-1 or vibe==1) and Duel.IsExistingMatchingCard(Card.IsAttackAbove,tp,LOCATION_MZONE,0,1,c,1))
	if chk==0 then return op1 or op2 end
	if op1 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil,mg)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_ONFIELD)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	end
end
function s.tlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local vibe=e:GetLabel()-1
	local mg=c:GetMaterial()
	if vibe==0 and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil,mg) then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
			if g:GetCount()>0 then
				Duel.HintSelection(g)
				g:AddCard(tc)
				Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
	if (vibe==-1 or vibe==1) and Duel.IsExistingMatchingCard(Card.IsAttackAbove,tp,LOCATION_MZONE,0,1,c,1) then
		local atk=0
		local g=Duel.GetMatchingGroup(Card.IsAttackAbove,tp,LOCATION_MZONE,0,c,1)
		local bc=g:GetFirst()
		while bc do
			atk=atk+bc:GetAttack()
			bc=g:GetNext()
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(s.ftarget)
		e2:SetLabel(c:GetFieldID())
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetDescription(aux.Stringid(id,0))
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end

function s.GetOriginalVibe(c)
	---1 = Negative; +0 = Neutral; +1 = Positive
	local batk,bdef
	if c:HasAttack() then
		batk=c:GetBaseAttack()
	end
	if c:HasDefense() then
		bdef=c:GetBaseDefense()
	end
	
	if not batk or not bdef then return end
	local stat=batk-bdef
	if stat==0 then
		return stat
	else
		return stat/math.abs(stat)
	end
end