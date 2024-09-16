--created by Seth, coded by Lyris
--Great London Criminal Masterminds
local s,id,o = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xd3f),4,2,nil,nil,99)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd3f))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetDescription(aux.Stringid(id//10,0))
	e2:SetCondition(s.sdcon)
	e2:SetCost(s.sdcost)
	e2:SetTarget(s.sdtg)
	e2:SetOperation(s.sdop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_START)
	e4:HOPT()
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
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
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
end
function s.sdop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id//10,0))
	local tc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_DECK,0,1,5,nil):GetFirst()
	if not tc then return end
	Duel.ShuffleDeck(tp)
	Duel.MoveSequence(tc,SEQ_DECKTOP)
	Duel.ConfirmDecktop(tp,1)
end
function s.discon(e,tp,_,_,ev,re,_,rp)
	return rp==1-tp and Duel.IsChainDisablable(ev) and re:IsHasCategory(CATEGORY_SPECIAL_SUMMON)
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
function s.destg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetBattleTarget(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.desop(e,tp)
	local bc=e:GetHandler():GetBattleTarget()
	if not (bc and bc:IsRelateToBattle()) or Duel.Destroy(bc,REASON_EFFECT)<1 then return end
	Duel.BreakEffect()
	Duel.Damage(1-tp,1000,REASON_EFFECT)
end
