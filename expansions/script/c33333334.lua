--Quartosigillo Shikigami
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	c:EnableReviveLimit()
	c:MustFirstBeSummoned(SUMMON_TYPE_DRIVE)
	--Drive Effects
	aux.AddDriveProc(c,8)
	local d1=c:DriveEffect(-2,0,CATEGORY_SEARCH+CATEGORY_TOHAND,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		aux.SearchTarget(aux.STFilter(Card.IsSetCard,0x7ea)),
		aux.SearchOperation(aux.STFilter(Card.IsSetCard,0x7ea))
	)
	local d2=c:OverDriveEffect(1,CATEGORY_DRAW,EFFECT_TYPE_IGNITION,EFFECT_FLAG_PLAYER_TARGET,nil,
		nil,
		nil,
		aux.DrawTarget(),
		aux.DrawOperation()
	)
	--Monster Effects
	--ss
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.DriveSummonedCond)
	e1:SetTarget(aux.SSTarget(aux.Filter(Card.IsSetCard,0x7ec),LOCATION_DECK,0,1,1))
	e1:SetOperation(aux.SSOperation(aux.Filter(Card.IsSetCard,0x7ec),LOCATION_DECK,0,1,1))
	c:RegisterEffect(e1)
	--add to hand
	c:SentToGYTrigger(false,3,CATEGORY_TOHAND,true,nil,
		aux.DueToHavingZeroEnergyCond,
		aux.DiscardCost(aux.Filter(Card.IsSetCard,0x7ea,0x7ec)),
		aux.SendToHandTarget(SUBJECT_THIS_CARD),
		aux.SendToHandOperation(SUBJECT_THIS_CARD)
	)
end
