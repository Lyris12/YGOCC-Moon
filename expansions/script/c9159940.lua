--Antico Protettore della Foschiaresta
--Scripted by: XGlitchy30

local s,id=GetID()

s.effect_text = [[
● Cannot be Normal Summoned while there is a face-up monster on the field.
● You can only use each effect of "Ancient Fogrest Protector" once per turn.

① During the Main Phase: When you activate this effect, you can also return this card you control to the hand; Special Summon 1 Level 3 or lower Beast, Beast-Warrior, Winged-Beast, Insect or Fairy monster from your hand or Deck, also you cannot Special Summon monsters for the rest of the turn, except Beast, Beast-Warrior, Winged-Beast, Insect and Fairy monsters. If you returned this card to the hand when you activated this effect, your opponent cannot activate cards or effects in response to this effect's activation.
② When this card is flipped face-up: Target 1 face-up Beast, Beast-Warrior, Winged-Beast, Insect or Fairy monster you control; it cannot be destroyed by battle, nor targeted by an opponent's card effect, until the end of the next turn.
]]

function s.initial_effect(c)
	--sumlimit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(s.sumcon)
	c:RegisterEffect(e1)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	e2:SetLabel(0)
	c:RegisterEffect(e2)
	--flip
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_FLIP)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(s.fliptg)
	e3:SetOperation(s.flipop)
	c:RegisterEffect(e3)
end

--cannot summon
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster()
end
function s.sumcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

--Activate
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsLevelBelow(3) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINGEDBEAST+RACE_INSECT+RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	if c:IsLocation(LOCATION_MZONE) and c:IsAbleToHandAsCost() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) and Duel.SendtoHand(c,nil,REASON_COST)>0 and c:IsLocation(LOCATION_HAND) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
	if e:GetLabel()==1 then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINGEDBEAST+RACE_INSECT+RACE_FAIRY)
end

--flip
function s.filter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINGEDBEAST+RACE_INSECT+RACE_FAIRY)
end
function s.fliptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(aux.tgoval)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2,true)
	end
end