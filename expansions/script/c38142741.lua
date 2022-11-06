--Droide Fatato
--Scripted by: XGlitchy30

local s,id=GetID()

s.effect_text = [[
● You can only use the ② effect of "Fairy Droid" once per turn.

① Cannot be destroyed by battle, nor targeted by your opponent's card effects if you have a Ritual Monster and a Ritual Spell both in your GY, or both among your banished cards.
② You can discard 1 card; add 1 Ritual Spell or 1 Ritual Monster from your Deck to your hand, and if you do, the first time you Ritual Summon exactly 1 monster this turn with the effect of a Ritual Spell with the same original name as the card you added with this effect, or the first time you Ritual Summon exactly 1 Ritual Monster this turn with the same original name as the card you added with this effect, this card gains ATK equal to the original ATK of the Ritual Summoned monster.
]]

function s.initial_effect(c)
	--Protection
	local e1=c:BattleProtection()
	e1:SetCondition(s.cond)
	local e2=c:TargetProtection(true)
	e2:SetCondition(s.cond)
	--Search
	local e3=Effect.CreateEffect(c)
	e3:Desc(0)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(aux.DiscardCost())
	e3:SetTarget(aux.SearchTarget(s.filter))
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.f1(c,tp)
	return c:NotBanishedOrFaceup() and c:IsMonster(TYPE_RITUAL) and Duel.GetFieldGroup(tp,c:GetLocation(),0):IsExists(s.f2,1,c)
end
function s.f2(c)
	return c:NotBanishedOrFaceup() and c:GetType()&(TYPE_SPELL+TYPE_RITUAL)==TYPE_SPELL+TYPE_RITUAL
end
function s.cond(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.f1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp)
end

function s.filter(c)
	return c:IsMonster(TYPE_RITUAL) or c:GetType()&(TYPE_SPELL+TYPE_RITUAL)==TYPE_SPELL+TYPE_RITUAL
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g,ct,ht=aux.SearchOperation(s.filter)(e,tp)
	if ht>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		local codes=g:GetFirst():GetOriginalCode()
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_ATKCHANGE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetLabel(codes)
		e1:SetCondition(s.atkcon)
		e1:SetOperation(s.atkop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.cf(c,code,re)
	return c:IsSummonType(SUMMON_TYPE_RITUAL)
		and (c:IsMonster(TYPE_RITUAL) and c:IsOriginalCode(code) or re and re:GetHandler():GetType()&TYPE_SPELL+TYPE_RITUAL==TYPE_SPELL+TYPE_RITUAL and re:GetHandler():IsOriginalCode(code))
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cf,1,nil,e:GetLabel(),re) and eg:FilterCount(Card.IsSummonType,nil,SUMMON_TYPE_RITUAL)==1
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=eg:Filter(s.cf,nil,e:GetLabel(),re):GetFirst()
	if ec and c:IsFaceup() then
		Duel.Hint(HINT_CARD,0,id)
		c:UpdateATK(ec:GetTextAttack(),true)
	end
end