--Artifact Alastair
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,6,s.sumcon,s.tlfilter)
	c:EnableReviveLimit()
	--During your opponent's turn, when your opponent activates a Spell/Trap card (Quick Effect): You can make the activated effect become "Banish this card, and if you do, destroy 1 Spell/Trap Card your opponent controls".
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.chcon)
	e1:SetTarget(s.chtg)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)
	--If this card is sent to the GY: You can target 1 "Artifact" monster in your GY, except "Artifact Alastair"; either Special Summon it or Set it in your Spell & Trap Zone as a Spell.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
function s.sumcon(e,c)
	return Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_SZONE,0,3,nil)
end
function s.tlfilter(c,e,mg)
	local tp=c:GetControler()
	local ef=e:GetHandler():GetFuture()
	return c:IsLevelBelow(ef-1) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,rp,0,LOCATION_ONFIELD,1,nil) end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetType()==TYPE_SPELL or c:GetType()==TYPE_TRAP then
		c:CancelToGrave(false)
	end
	if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.setfilter(c,tp)
	return c:IsSetCard(0x97) and c:IsMonster() and not c:IsCode(id) and c:IsSSetable(true) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.spfilter(c,tp,e)
	return c:IsSetCard(0x97) and c:IsMonster() and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.tgfilter(c,tp,e)
	return c:IsSetCard(0x97) and c:IsMonster() and not c:IsCode(id) and 
		((c:IsSSetable(true) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) or (c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0))
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil,tp,e) end
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp,e)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local spcondition=Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil,tp,e)
	local setcondition=Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	local op=0
	if spcondition and setcondition then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif spcondition then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	local tc=Duel.GetFirstTarget()
	if op==0 then
		if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			Duel.SpecialSummonComplete()
		end
	else
		if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			Duel.SSet(tp,tc)
		end
	end
end