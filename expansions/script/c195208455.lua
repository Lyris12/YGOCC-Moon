--created by Seth, coded by Lyris
--Great London Crime Solvers
local s,id,o = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xd3f),4,2,nil,nil,99)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetDescription(aux.Stringid(id//10,0))
	e1:SetCondition(s.sdcon)
	e1:SetCost(s.sdcost)
	e1:SetTarget(s.sdtg)
	e1:SetOperation(s.sdop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetDescription(1131)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_START)
	e3:HOPT()
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
function s.sdcon()
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.sdcost(e,tp,_,_,_,_,_,_,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.sdtg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0xd3f) end
end
function s.sdop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id//10,0))
	local tc=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0xd3f):GetFirst()
	if not tc then return end
	Duel.ShuffleDeck(tp)
	Duel.MoveSequence(tc,SEQ_DECKTOP)
	Duel.ConfirmDecktop(tp,1)
end
function s.discon(e,tp,_,_,ev,_,_,rp)
	return s.sdcon() and rp==1-tp and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	e:SetLabel(Duel.AnnounceType(tp))
end
function s.disop(e,tp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	local tc=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	Duel.ConfirmDecktop(1-tp,1)
	if tc:IsType(1<<e:GetLabel()) then Duel.NegateEffect(ev) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d3f)
end
function s.descon(e,tp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsRelateToBattle()
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.destg(e,_,_,_,_,_,_,_,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetBattleTarget(),1,0,0)
end
function s.sfilter(c)
	return c:IsSetCard(0xd3f) and c:IsAbleToHand()
end
function s.desop(e,tp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK,0,nil)
	if not (bc and bc:IsRelateToBattle()) or Duel.Destroy(bc,REASON_EFFECT)<1 or #g<1
		or not Duel.SelectEffectYesNo(tp,c,1190) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,1,nil)
	Duel.BreakEffect()
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
