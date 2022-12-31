--Divexplorer (Wincon)
local ref,id=GetID()
function ref.initial_effect(c)
	aux.AddLinkProcedure(c,nil,2,2,ref.matgfilter)
	--Banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	--e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(ref.rmtg)
	e1:SetOperation(ref.rmop)
	c:RegisterEffect(e1)
	--Restrict
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_REPEAT)
	e2:SetOperation(ref.disop)
	c:RegisterEffect(e2)
end
function ref.matgfilter(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_FISH)
end

--Banish
function ref.rmfilter(c)
	return c:IsSetCard(0x72e) and c:IsAbleToRemove()
end
function ref.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function ref.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,ref.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
end

function ref.disfilter(c)
	return c:IsSetCard(0x72e) and c:IsFaceup()
end
function ref.disloop(c,e,tp)
	local seq=c:GetSequence()
	if seq==5 or seq==6 then
		if seq==5 then seq=1 else seq=3 end
	end
	if c:IsControler(tp) then seq = 4-seq end --flips left-to-right (so it'll be correct after flipping sides)
	seq = seq+8+16 --+8 swaps from MZONE to SZONE, +16 swaps from player side to opponent side
	local val=bit.bor(e:GetLabel(), bit.lshift(1,seq))
	e:SetLabel(val)
end
function ref.disop(e,tp)
	local g=Duel.GetMatchingGroup(ref.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	e:SetLabel(0)
	g:ForEach(ref.disloop,e,tp)
	return e:GetLabel()
end

