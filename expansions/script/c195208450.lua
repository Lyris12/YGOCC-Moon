--created by Seth, coded by Lyris
--Great London Detective Polan
local s,id,o = GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetDescription(1152)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetDescription(aux.Stringid(id//10,0))
	e2:SetOperation(s.sdop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetDescription(1190)
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLE_START)
	e5:HOPT()
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
function s.spcon()
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.sptg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	e:SetLabel(Duel.AnnounceType(tp))
end
function s.spop(e,tp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)<1 then return end
	local tc=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	Duel.ConfirmDecktop(1-tp,1)
	if not tc:IsType(1<<e:GetLabel()) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end
function s.sdop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id//10,0))
	local tc=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0xd3f):GetFirst()
	if not tc then return end
	Duel.ShuffleDeck(tp)
	Duel.MoveSequence(tc,SEQ_DECKTOP)
	Duel.ConfirmDecktop(tp,1)
end
function s.thtg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	e:SetLabel(Duel.AnnounceType(tp))
end
function s.thop(e,tp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)<1 then return end
	local tc=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	Duel.ConfirmDecktop(1-tp,1)
	if tc:IsType(1<<e:GetLabel()) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d3f)
end
function s.descon(e,tp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsRelateToBattle()
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,3,nil)
end
function s.destg(e,_,_,_,_,_,_,_,,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetBattleTarget(),1,0,0)
end
function s.desop(e,tp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not (bc and bc:IsRelateToBattle()) or Duel.Destroy(bc,REASON_EFFECT)<1 then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetReset(RESET_EVENT+RESETS_STANDAR+RESET_PHASE+PHASE_BATTLE)
	bc:RegisterEffect(e1)
end
