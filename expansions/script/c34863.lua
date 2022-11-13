--Database Driver
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,4)
	local d1=c:DriveEffect(-2,0,CATEGORY_TOHAND,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		aux.Target(aux.ToHandFilter(Card.IsSpellTrapOnField),0,LOCATION_ONFIELD,1,1,nil,nil,CATEGORY_TOHAND),
		aux.SendToHandOperation(SUBJECT_IT)
	)
	local d2=c:DriveEffect(-2,1,CATEGORY_DRAW+CATEGORY_REMOVE,EFFECT_TYPE_IGNITION,EFFECT_FLAG_PLAYER_TARGET,nil,
		nil,
		nil,
		s.drawtg,
		s.drawop
	)
	--Monster Effects
	--search dupe
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.DriveSummonedCond)
	e1:SetTarget(aux.SearchTarget(aux.Filter(Card.IsCode,63995093)))
	e1:SetOperation(aux.SearchOperation(aux.Filter(Card.IsCode,63995093)))
	c:RegisterEffect(e1)
	--search monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(aux.MainPhaseCond())
	e2:SetCost(aux.TributeCost(aux.MonsterFilter(Card.IsRace,RACE_MACHINE)),1,1,true)
	e2:SetTarget(aux.SearchTarget(s.thfilter))
	e2:SetOperation(aux.SearchOperation(s.thfilter))
	c:RegisterEffect(e2)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,30459350) and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
	Duel.ShuffleHand(p)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.GetMatchingGroup(Card.IsMonster,p,LOCATION_HAND,0,nil,TYPE_DRIVE)
	if #g>0 then
		local tg=g:FilterSelect(p,Card.IsAbleToRemove,1,1,nil)
		if #tg>0 then
			if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)==0 then
				Duel.ConfirmCards(1-p,tg)
				Duel.ShuffleHand(p)
			end
		else
			tg=g:Select(p,1,1,nil)
			Duel.ConfirmCards(1-p,tg)
			Duel.ShuffleHand(p)
		end
	else
		local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end

function s.thfilter(c)
	return c:IsMonster() and c:IsRace(RACE_MACHINE) and (c:IsAttack(500) or c:IsDefense(500)) and not c:IsCode(id)
end