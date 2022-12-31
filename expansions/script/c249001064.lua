--Future Arcane-Caster
function c249001064.initial_effect(c)
	c:EnableCounterPermit(0x26)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunFunRep(c,aux.TRUE,aux.FilterBoolFunction(Card.IsFusionSetCard,0x226),2,2,true)
	aux.AddContactFusionProcedure(c,Card.IsReleasable,LOCATION_MZONE,0,Duel.Release,REASON_COST+REASON_MATERIAL)
	--disable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c249001064.disop)
	c:RegisterEffect(e1)	
	--spsummon condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c249001064.splimit)
	c:RegisterEffect(e2)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c249001064.reptg)
	c:RegisterEffect(e3)
	--summon success
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(7200041,0))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c249001064.addct)
	e4:SetOperation(c249001064.addc)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e6)
	--discard deck
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(2061963,1))
	e7:SetCategory(CATEGORY_DECKDES)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTarget(c249001064.decktg)
	e7:SetOperation(c249001064.deckop)
	c:RegisterEffect(e7)
	--add counter draw
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EVENT_DRAW)
	e8:SetCondition(aux.TRUE)
	e8:SetTarget(c249001064.addct2)
	e8:SetOperation(c249001064.addc2)
	c:RegisterEffect(e8)
end
function c249001064.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsContains(e:GetHandler()) or not Duel.IsChainDisablable(ev) then return false end
	if re:IsActiveType(TYPE_MONSTER) then ct=re:GetHandler():GetAttack() else ct=1000 end
	if e:GetHandler():IsCanRemoveCounter(tp,0x26,ct,REASON_EFFECT) and Duel.SelectYesNo(tp,10) then
		e:GetHandler():RemoveCounter(tp,0x26,ct,REASON_EFFECT)
		Duel.NegateEffect(ev)
	end
end
function c249001064.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c249001064.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct
	if r==REASON_BATTLE then ct=e:GetHandler():GetBattleTarget():GetAttack() elseif re:IsActiveType(TYPE_MONSTER) then ct=re:GetHandler():GetAttack() else ct=1000 end
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x26,ct,REASON_EFFECT) end
	e:GetHandler():RemoveCounter(tp,0x26,ct,REASON_EFFECT)
	return true
end
function c249001064.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x26)
	Duel.SetChainLimit(aux.FALSE)
end
function c249001064.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x26,4000)
	end
end
function c249001064.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function c249001064.filter(c,lv,race,att)
	return c:GetLevel()==lv and c:IsRace(race) and c:IsAttribute(att) and c:IsAbleToHand()
end
function c249001064.filter2(c,type)
	return c:GetType()==type and c:CheckActivateEffect(false,false,false) and c:IsAbleToDeck()
end
function c249001064.deckop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.DiscardDeck(p,d,REASON_EFFECT)
	local g1=Duel.GetOperatedGroup()
	local tc=g1:GetFirst()
	if tc then
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(c249001064.filter,tp,LOCATION_DECK,0,1,nil,tc:GetLevel(),tc:GetRace(),tc:GetAttribute())
		and Duel.SelectYesNo(tp,1161) then
			local g2=Duel.SelectMatchingCard(tp,c249001064.filter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel(),tc:GetRace(),tc:GetAttribute())
			if g2:GetCount()>0 then
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g2)
			end			
		elseif (tc:GetType()==0x2 or tc:GetType()==0x4 or tc:GetType()==0x10002) and Duel.IsExistingMatchingCard(c249001064.filter2,tp,LOCATION_GRAVE,0,1,nil,tc:GetType())
		and Duel.SelectYesNo(tp,1161) then
			local g2=Duel.SelectMatchingCard(tp,c249001064.filter2,tp,LOCATION_GRAVE,0,1,1,nil,tc:GetType())
			tc=g2:GetFirst()
			local tpe=tc:GetType()
			local te=tc:GetActivateEffect()
			local tg=te:GetTarget()
			local co=te:GetCost()
			local op=te:GetOperation()
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			if bit.band(tpe,TYPE_EQUIP+TYPE_CONTINUOUS)~=0 or tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
				if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			elseif bit.band(tpe,TYPE_FIELD)~=0 then
				Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			end
			tc:CreateEffectRelation(te)
			if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
			if tg then
				if tc:IsSetCard(0x95) then
					tg(e,tp,eg,ep,ev,re,r,rp,1)
				else
					tg(te,tp,eg,ep,ev,re,r,rp,1)
				end
			end
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if not g then g=Group.CreateGroup() end
			local etc=g:GetFirst()
			while etc do
				etc:CreateEffectRelation(te)
				etc=g:GetNext()
			end
			if op then 
				if tc:IsSetCard(0x95) then
					op(e,tp,eg,ep,ev,re,r,rp)
				else
					op(te,tp,eg,ep,ev,re,r,rp)
				end
			end
			tc:ReleaseEffectRelation(te)
			etc=g:GetFirst()
			while etc do
				etc:ReleaseEffectRelation(te)
				etc=g:GetNext()
			end
			Duel.BreakEffect()
			Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		end
	end
end
function c249001064.addct2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x26)
end
function c249001064.addc2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x26,1500)
	end
end