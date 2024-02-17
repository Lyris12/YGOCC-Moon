--Conjuration Mage Knight of Prophecy EX
function c249001290.initial_effect(c)
	c:SetUniqueOnField(1,0,249001290)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunFun(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),aux.FilterBoolFunction(Card.IsFusionSetCard,0x6E),2,false)
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(510)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY_EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c249001290.settg)
	e1:SetOperation(c249001290.setop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91998119,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c249001290.descost)
	e2:SetTarget(c249001290.destg)
	e2:SetOperation(c249001290.desop)
	c:RegisterEffect(e2)
	--sp summon condition
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c249001290.splimit)
	c:RegisterEffect(e3)
	--create
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetCountLimit(1)
	e4:SetTarget(c249001290.crtg)
	e4:SetOperation(c249001290.crop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_BECOME_TARGET)
	e6:SetCountLimit(1)
	e6:SetCondition(c249001290.crcon)
	e6:SetTarget(c249001290.crtg)
	e6:SetOperation(c249001290.crop)
	c:RegisterEffect(e6)
end
function c249001290.setfilter(c)
	return c:IsSetCard(0x106E) and c:IsSetCard(0x239) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function c249001290.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249001290.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function c249001290.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001290.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then Duel.SSet(tp,tc) end
end
function c249001290.splimit(e,se,sp,st)
	return st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION or e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c249001290.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c249001290.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c249001290.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function c249001290.filter(c)
	return c:IsSetCard(0x106E) and c:IsSetCard(0x239) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c.card_code_list
end
function c249001290.crtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c249001290.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c249001290.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	local g=Duel.SelectTarget(tp,c249001290.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
end
function c249001290.spellfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not global_card_effect_table[c] then return false end
	for key,value in pairs(global_card_effect_table[c]) do
		if value and value:GetCode()==EFFECT_REMAIN_FIELD then
			return false
		end
	end
	local te=c:CheckActivateEffect(false,false,false)
	if c:IsType(TYPE_SPELL) and not c:IsType(TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD) and te then
		if c:IsSetCard(0x95) then
			local tg=te:GetTarget()
			return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)
		else
			return true
		end
	end
	return false
end
function c249001290.crop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local g=Group.CreateGroup()
	local mt=getmetatable(tc)
	for key,value in pairs(mt.card_code_list) do
		local token=Duel.CreateToken(tp,key)
		g:AddCard(token)
	end
	local sg=g:RandomSelect(tp,1,1)
	Duel.SendtoHand(sg,nil,REASON_RULE)
	if not Duel.IsExistingMatchingCard(c249001290.spellfilter,tp,LOCATION_HAND,0,1,nil,e,tp,eg,ep,ev,re,r,rp) or not Duel.SelectEffectYesNo(tp,c) then return end
	Duel.BreakEffect()
	g=Duel.SelectMatchingCard(tp,c249001290.spellfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	tc=g:GetFirst()
	if not tc or Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)==0 then return end
	local tpe=tc:GetType()
	local te=tc:GetActivateEffect()
	local tg=te:GetTarget()
	local co=te:GetCost()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	Duel.BreakEffect()
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
	g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
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
end
function c249001290.crcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end