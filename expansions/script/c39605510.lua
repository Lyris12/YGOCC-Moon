--Zextra, The Pandemonium Dragon King
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	aux.EnablePandemoniumAttribute(c,true,TYPE_EFFECT+TYPE_SPSUMMON,false,cid.actcost)
	--You can only Pandemonium Summon Pandemonium Monsters. This effect cannot be negated.
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e5:SetTargetRange(1,0)
	e5:SetTarget(cid.splimit)
	c:RegisterEffect(e5)
	--Pandemonium Summoned monsters can attack twice on monsters during the turn they're Pandemonium Summoned.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(aux.PandActCheck)
	e1:SetTarget(function(e,c) return c:IsSummonType(SUMMON_TYPE_SPECIAL+726) and c:IsStatus(STATUS_SPSUMMON_TURN) end)
	e1:SetValue(2)
	c:RegisterEffect(e1)
	--Must be Special Summoned by the effect of "Zextral Armageddon Sorcerer" or Pandemonium Summoned while "Zextral Armageddon Sorcerer" is in the Pandemonium Zone.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(cid.spcon)
	c:RegisterEffect(e2)
	--If this card is Summoned: All other face-up monsters' ATK and DEF on the field become 0.
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetOperation(cid.atkop)
	c:RegisterEffect(e6)
	local e0=e6:Clone()
	e0:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e0)
	local e1x=e6:Clone()
	e1x:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e1x)
	--When a Spell/Trap Card or another monster's effect is activated (Quick Effect): You can shuffle 1 face-up Pandemonium Monster from your Extra Deck into the Deck, negate the activation, and if you do, destroy that card.
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e7:SetCode(EVENT_CHAINING)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e7:SetCondition(cid.negcon)
	e7:SetCost(cid.negcost)
	e7:SetTarget(cid.negtg)
	e7:SetOperation(cid.negop)
	c:RegisterEffect(e7)
	--This card's maximum number of attacks on monsters during the Battle Phase is equal to the number of face-up Pandemonium Monsters in your Extra Deck with different names.
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e8:SetRange(LOCATION_MZONE)
	e8:SetValue(cid.atkval)
	c:RegisterEffect(e8)
	local e8x=Effect.CreateEffect(c)
	e8x:SetType(EFFECT_TYPE_SINGLE)
	e8x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8x:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e8x:SetRange(LOCATION_MZONE)
	e8x:SetCondition(cid.atkprev)
	e8x:SetValue(1)
	c:RegisterEffect(e8x)
end
function cid.acfilter(c,g)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xf79) or (c:IsSetCard(0xcf80) and g:IsExists(Card.IsSetCard,1,c,0xcf80)))
end
function cid.acfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xcf80)
end
function cid.actchk(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetReleaseGroup(tp)
	return not g:IsExists(cid.acfilter,1,nil,g)
end
function cid.actcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()==e:GetHandler()
end
function cid.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetReleaseGroup(tp)
		return g:IsExists(cid.acfilter,1,nil,g)
	end
	local g=Duel.GetReleaseGroup(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=g:FilterSelect(tp,cid.acfilter,1,1,nil,g)
	if #rg>0 then
		if not rg:GetFirst():IsSetCard(0xf79) then
			local rg2=g:FilterSelect(tp,cid.acfilter2,1,1,rg)
			if #rg2<=0 then return end
			rg:Merge(rg2)
		end
		Duel.Release(rg,REASON_COST)
	end
end
function cid.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsType(TYPE_PANDEMONIUM) then return false end
	return aux.PandActCheck(e) and bit.band(sumtype,SUMMON_TYPE_SPECIAL+726)==SUMMON_TYPE_SPECIAL+726
end
function cid.spcon(e,se,sp,st)
	return (Duel.IsExistingMatchingCard(function(c) return c:IsCode(39615023) and c:IsFaceup() end,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
		and bit.band(st,SUMMON_TYPE_SPECIAL+726)==SUMMON_TYPE_SPECIAL+726) or (se and se:GetHandler():IsCode(39615023))
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
function cid.negcon(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or (re:IsActiveType(TYPE_MONSTER) and re:GetHandler()~=e:GetHandler()))
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function cid.filter(c)
	return c:IsType(TYPE_PANDEMONIUM) and c:IsFaceup()
end
function cid.cfilter(c)
	return cid.filter(c) and c:IsAbleToDeckAsCost()
end
function cid.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,2,REASON_COST)
	end
end
function cid.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cid.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function cid.atkval(e)
	return Duel.GetMatchingGroup(cid.filter,e:GetHandlerPlayer(),LOCATION_EXTRA,0,nil):GetClassCount(Card.GetCode)-1
end
function cid.atkprev(e)
	return Duel.GetMatchingGroupCount(cid.filter,e:GetHandlerPlayer(),LOCATION_EXTRA,0,nil)<=0
end